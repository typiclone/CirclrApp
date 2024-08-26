//
//  ViewController.swift
//  Circlr
//
//  Created by Vasisht Muduganti on 8/13/24.
//
import CoreLocation
import CoreMotion
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var startingLocation: CLLocation?
    let motionManager = CMMotionManager()
    var lapCounter = 0
    var checkpoints = [0,90,180,270]
    var reverseCheckPoints = [0,90,180,270]
    var currentCheckpoint = 0
    var currentCheckpointSelected = 0
    var degrees:Double = 0.0
    var initialDegree = -1
    var firstCheckPointReached = false
    var circularProgressView: CircularProgressView!
    var counterCircularProgressView: CircularProgressView!
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Distance: 0.0 meters"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    var clockwise = false
    let lapLabel: UILabel = {
        let label = UILabel()
        label.text = "Laps: 0"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    let checkpointLabel: UILabel = {
        let label = UILabel()
        label.text = "Checkpoint: 0"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    let setStartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set Starting Point", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        smooth = [Double]()
        setupUI()
        setupLocationManager()
        setupMotionManager()
        last2Checkpoints = []
        setStartButton.addTarget(self, action: #selector(setStartingPoint), for: .touchUpInside)
        
        circularProgressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        circularProgressView.center = view.center
        
        view.addSubview(circularProgressView)
        
        /*counterCircularProgressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), clockwise: false)
        counterCircularProgressView.center = view.center
        counterCircularProgressView.frame.origin.x = 0
       
        //counterCircularProgressView.mirrorHorizontally()
        view.addSubview(counterCircularProgressView)*/
               
               // Start updating the circle
        updateCircleProgress()
    }
    var highestDegreeInCurrentLap = 0
    func updateCircleProgress() {
            // Simulate real-time updates
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
          
                    
            if firstCheckPointReached == true{
                print(highestDegreeInCurrentLap)
                self.circularProgressView.setProgress(to: CGFloat(highestDegreeInCurrentLap), didFinish: firstCheckPointReached, clockwise: clockwise)
            }
            else{
                self.circularProgressView.setProgress(to: CGFloat(indicatorAngle), didFinish: firstCheckPointReached, clockwise: clockwise)
            }
                //self.circularProgressView.setProgress(to: Float(CGFloat(self.indicatorAngle/360.0)))
                //self.counterCircularProgressView.setProgress(to: Float(CGFloat(self.indicatorAngle/360.0)))
                
                
            }
        }
    func setupUI() {
        view.addSubview(distanceLabel)
        view.addSubview(lapLabel)
        view.addSubview(checkpointLabel)
        view.addSubview(setStartButton)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        lapLabel.translatesAutoresizingMaskIntoConstraints = false
        checkpointLabel.translatesAutoresizingMaskIntoConstraints = false
        setStartButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distanceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            lapLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lapLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 20),
            
            checkpointLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkpointLabel.topAnchor.constraint(equalTo: lapLabel.bottomAnchor, constant: 20),
            
            setStartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setStartButton.topAnchor.constraint(equalTo: checkpointLabel.bottomAnchor, constant: 20)
        ])
    }
    var angleY: Double = 0.0
    var lastTimestamp: TimeInterval?

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func setupMotionManager() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak self] (motion, error) in
                guard let self = self, let motion = motion, error == nil else {
                    return
                }
                let yawDegrees = self.calculateYawDegrees(from: motion.attitude.quaternion)
                
                
                
                DispatchQueue.main.async { [self] in
                    self.degrees = yawDegrees
                    
                    if self.initialDegree != -1{
                        self.checkForCheckpointCrossing(degrees: yawDegrees)
                    }
                   // print("Accurate Yaw (rotation around y-axis, independent of tilt): \(self.degrees) degrees")
                }
            }
        }
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
                guard let self = self, let accelerometerData = data else { return }
                self.processAccelerometerData(accelerometerData)
            }
        }
    }
    var last2Checkpoints:[Int]?
    func returnCheckpointArea() -> Int{
       // print("gangshy", checkpoints)
        
            var closestIndex = 0
        var minDistance = Int.max
            
            for (index, checkpoint) in checkpoints.enumerated() {
                // Calculate direct distance
                let directDistance = abs(Int(degrees) - checkpoint)
                
                // Calculate the wrapped distance over 360 degrees
                let wrappedDistance = min(directDistance, 360 - directDistance)
                
                if wrappedDistance < Int(minDistance) {
                    minDistance = wrappedDistance
                    closestIndex = index
                }
            }
        if closestIndex == 3{
            if last2Checkpoints?.count ?? 0 >= 1{
                if 0 != last2Checkpoints![last2Checkpoints!.count - 1]{
                    if last2Checkpoints?.count == 2{
                        last2Checkpoints?.remove(at: 0)
                    }
                    last2Checkpoints?.append(0)
                }
            }
            else{
                last2Checkpoints?.append(0)
            }
            return 0
        }
        else if closestIndex == 1 || closestIndex == 0 || closestIndex == 2{
            if last2Checkpoints?.count ?? 0 >= 1{
                if closestIndex + 1 != last2Checkpoints![last2Checkpoints!.count - 1]{
                    if last2Checkpoints?.count == 2{
                        last2Checkpoints?.remove(at: 0)
                    }
                    last2Checkpoints?.append(closestIndex + 1)
                }
            }
            else{
                last2Checkpoints?.append(closestIndex + 1)
            }
            return closestIndex + 1
        }
        return 0
        
        /*for i in 0...2 {
            //if clockwise == false{
                if checkpoints[i + 1] < checkpoints[i]{
                    if (Int(degrees) <= checkpoints[i + 1] && degrees >= 0) || Int(degrees) >= checkpoints[i] && degrees <= 360{
                        return i + 1
                    }
                }
                if Int(degrees) >= checkpoints[i] && Int(degrees) <= checkpoints[i + 1]{
                    return i + 1
                }
            //}
            /*else{
                if checkpoints[i + 1] > checkpoints[i]{
                    if (Int(degrees) <= checkpoints[i] && degrees >= 0) || Int(degrees) <= checkpoints[i + 1]{
                        return i + 1
                    }
                }
                if Int(degrees) <= checkpoints[i] && Int(degrees) >= checkpoints[i + 1]{
                    return i + 1
                }
            }*/
        }
        return 0*/
        
    }
    var indicatorAngle = 0.0
    // Separate function to calculate yaw degrees from the quaternion
    func calculateYawDegrees(from quaternion: CMQuaternion) -> Double {
        let yawRadians = atan2(2.0 * (quaternion.x * quaternion.y + quaternion.w * quaternion.z),
                               quaternion.w * quaternion.w + quaternion.x * quaternion.x - quaternion.y * quaternion.y - quaternion.z * quaternion.z)
        
        var degrees = yawRadians * 180 / .pi
        degrees = fmod(degrees, 360)
        //print(degrees)
        if degrees < 0 {
            degrees += 360
        }
        var diff = self.degrees - degrees
        if self.degrees != 0{
            indicatorAngle += diff
            if indicatorAngle < 0{
                indicatorAngle = indicatorAngle + 360
            }
            else if indicatorAngle > 360{
                indicatorAngle = indicatorAngle - 360
            }
        }
        /*if indicatorAngle > 270{
            self.circularProgressView.layer.opacity = 0.0
            self.counterCircularProgressView.layer.opacity = 1.0
        }
        else{
            self.circularProgressView.layer.opacity = 1.0
            self.counterCircularProgressView.layer.opacity = 0.0
        }*/
       // print(indicatorAngle)
        
        return degrees
    }
    
    // Separate function to check for checkpoint crossing and update lap counter
    func generateLightHapticFeedback() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    func resetCircleData(){
        //self.circularProgressView.resetProgress(animated: true, duration: 0.5, clockwise: clockwise)
        if clockwise == true{
            highestDegreeInCurrentLap = 0
        }
        else{
            highestDegreeInCurrentLap = 360
        }
        
        indicatorAngle = 0
    }
    func checkForDirection(){
        if firstCheckPointReached == false{
            var lowerBound = checkpoints[0] - 10
            var upperBound = checkpoints[0] + 10
            
            var otherlowerBound = (checkpoints[checkpoints.count - 2] ?? 0) - 10
            var otherupperBound = (checkpoints[checkpoints.count - 2] ?? 0) + 10
            
            if lowerBound < 0 {
                lowerBound = 360 + lowerBound
            }
            if upperBound > 360 {
                upperBound = upperBound - 360
            }
            
            if otherlowerBound < 0 {
                otherlowerBound = 360 + otherlowerBound
            }
            if otherupperBound > 360 {
                otherupperBound = otherupperBound - 360
            }
            
            if lowerBound < upperBound{
                if Int(degrees) >= lowerBound && Int(degrees) <= upperBound {
                    if currentCheckpoint == 3 {
                        lapCounter += 1
                        resetCircleData()
                        currentCheckpoint = 0
                    }
                    else{
                        currentCheckpoint += 1
                    }
                    clockwise = false
                    firstCheckPointReached = true
                    highestDegreeInCurrentLap = Int(indicatorAngle)
                    generateLightHapticFeedback()
                }
            }
            else if lowerBound > upperBound && firstCheckPointReached == false{
                if (degrees >= 0 && Int(degrees) <= upperBound) || (Int(degrees) >= lowerBound && degrees <= 360){
                    if currentCheckpoint == 3 {
                        lapCounter += 1
                        resetCircleData()
                        currentCheckpoint = 0
                    }
                    else{
                        currentCheckpoint += 1
                    }
                    clockwise = false
                    firstCheckPointReached = true
                    highestDegreeInCurrentLap = Int(indicatorAngle)
                    generateLightHapticFeedback()
                }
            }
            
            if otherlowerBound < otherupperBound && firstCheckPointReached == false{
                if Int(degrees) >= otherlowerBound && Int(degrees) <= otherupperBound {
                    if currentCheckpoint == 3 {
                        lapCounter += 1
                        resetCircleData()
                        currentCheckpoint = 0
                    }
                    else{
                        currentCheckpoint += 1
                    }
                    reverseCheckPoint()
                    clockwise = true
                    firstCheckPointReached = true
                    highestDegreeInCurrentLap = Int(indicatorAngle)
                    generateLightHapticFeedback()
                }
            }
            else if otherlowerBound > otherupperBound && firstCheckPointReached == false{
                if (degrees >= 0 && Int(degrees) <= otherupperBound) || (Int(degrees) >= otherlowerBound && degrees <= 360){
                    if currentCheckpoint == 3 {
                        lapCounter += 1
                        resetCircleData()
                        currentCheckpoint = 0
                    }
                    else{
                        currentCheckpoint += 1
                    }
                    clockwise = true
                    reverseCheckPoint()
                    firstCheckPointReached = true
                    highestDegreeInCurrentLap = Int(indicatorAngle)
                    generateLightHapticFeedback()
                }
            }
            
            
        }
    }
    func reverseCheckPoint(){
        var temp1 = checkpoints[0]
        checkpoints[0] = checkpoints[2]
        checkpoints[2] = temp1
    }
    func checkForCheckpointCrossing(degrees: Double) {
        var newCheckpoint = self.returnCheckpointArea()
        //print(currentCheckpoint, newCheckpoint)
        
        if firstCheckPointReached == false{
            checkForDirection()
            //print("konichiwa ", checkpoints)
        }
        else{
            if clockwise == true && abs(Int(indicatorAngle) - highestDegreeInCurrentLap) <= 30{
                highestDegreeInCurrentLap = max(highestDegreeInCurrentLap, Int(indicatorAngle))
            }
            else if abs(Int(indicatorAngle) - highestDegreeInCurrentLap) <= 30{
                highestDegreeInCurrentLap = min(highestDegreeInCurrentLap, Int(indicatorAngle))
            }
            var lowerBound = checkpoints[currentCheckpoint] - 10
            var upperBound = checkpoints[currentCheckpoint] + 10
            
            if lowerBound < 0 {
                lowerBound = 360 + lowerBound
            }
            if upperBound > 360 {
                upperBound = upperBound - 360
            }
            //print(lowerBound, upperBound)
            if lowerBound < upperBound{
                if Int(degrees) >= lowerBound && Int(degrees) <= upperBound {
                    updateCheckpointCounter()
                }
            }
            else if lowerBound > upperBound{
                if (degrees >= 0 && Int(degrees) <= upperBound) || (Int(degrees) >= lowerBound && degrees <= 360){
                    updateCheckpointCounter()
                }
            }
            updateCheckPointCounterLabel()
            updateLapCount()
        }
        
    }
    func updateCheckpointCounter(){
        var newCheckpoint = 0
        //print(currentCheckpoint,last2Checkpoints)
        if last2Checkpoints?.contains(currentCheckpoint) == false{
            return
        }
        //print(currentCheckpoint, newCheckpoint)
        if currentCheckpoint == 3 {
            lapCounter += 1
            resetCircleData()
            currentCheckpoint = 0
        }
        else{
            currentCheckpoint += 1
        }
        generateLightHapticFeedback()
    }
    func processAccelerometerData(_ data: CMAccelerometerData) {
        // Handle accelerometer data
        calculateVelocity(acceleration: data.acceleration)
        /*if isWalking(acceleration: data.acceleration) {
                    print("Device is moving like walking")
                    // Execute your code here
                } else {
                    print("Device is not moving like walking")
                }*/
    }
    var velocityX: Double = 0.0
    var velocityY: Double = 0.0
    func calculateVelocity(acceleration: CMAcceleration) {
        // Convert the update interval to seconds
        
    }
    func isWalking(acceleration: CMAcceleration) -> Bool {
        
        let horizontalThreshold: Double = 0.02 // Adjust this threshold to detect horizontal movement
        let verticalThreshold: Double = 1.0 // Higher threshold for vertical to ignore minor up/down motion
        
        // Focus on horizontal movement (x and y) while ignoring significant up/down motion (z)
        let isMovingHorizontally = (abs(acceleration.x) > horizontalThreshold) || (abs(acceleration.y) > horizontalThreshold)
        //let isNotMovingVertically = abs(acceleration.z) < verticalThreshold
        
        return isMovingHorizontally
    }
    func updateCheckPointCounterLabel(){
        checkpointLabel.text = "Checkpoint: \(currentCheckpoint)"
    }
    func updateLapCount(){
        lapLabel.text = "Laps: \(lapCounter)"
    }
    
    var accel = 0.0
    var motion = 0.0
    /*func processAccelerometerData(_ data: CMAccelerometerData) {
            let acceleration = data.acceleration
                
                // Assuming gravity is approximately 9.8 m/s^2
        //print(acceleration.z)
            // Example logic to detect specific movement patterns or thresholds
            // You can use acceleration data to detect specific patterns or thresholds
            // for lap detection or movement tracking
        }*/
    @objc func setStartingPoint() {
        if let currentLocation = locationManager.location {
            startingLocation = currentLocation
            lapCounter = 0 // Reset lap counter
            distanceLabel.text = "Starting point set"
            lapLabel.text = "Laps: \(lapCounter)"
            firstCheckPointReached = false
            initialDegree = Int(degrees)
            indicatorAngle = 0
            currentCheckpoint = 0
            currentCheckpointSelected = 0
            highestDegreeInCurrentLap = 0
            var baseCount = initialDegree
            
            for i in 0..<checkpoints.count{
                baseCount = baseCount + 90
                if baseCount > 360{
                    baseCount = baseCount - 360
                }
                checkpoints[i] = baseCount
            }
            updateCheckPointCounterLabel()
            updateLapCount()
            print("lordy \(checkpoints)")
        }
    }
    var smooth:[Double]?
    var averagedValue = 100.0
    var lastLapTimestamp: Date?
    private let lapCooldown: TimeInterval = 0.1
    
    
    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        if let startLocation = startingLocation {
            let distance = currentLocation.distance(from: startLocation)
            distanceLabel.text = String(format: "Distance: %.2f meters", distance)
        }
        var speed: CLLocationSpeed = CLLocationSpeed()
        speed = locationManager.location?.speed ?? 0
        //print(speed)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
