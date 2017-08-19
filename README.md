# Robotics Perception
This repository consist of MATLAB code for different projects completed as part of the course in *ENPM673: Perception for Autonomous Robots* at the University of Maryland. Following sections describe the projects in brief.
### Augmented Reality and Tag Detection
---------------------------------------
This project identifies the tag id from a series of frames taken from a drone attached camera. The direct application of this project is aid the landing of a drone by recognizing the appropriate tag id from the downward facing camera. The QR tags are a simplified version that can encode ids from 0 to 15[8 bits]. The four corner points were robustly estimated across all frames, based on which homography calculations were performed to recover the camera pose. This information was later use to project a virtual cube in the scene.
<p align="center">
  <img src="https://github.com/rishabh1b/RoboticsPerception/blob/master/gifs/virtualCube.gif?raw=true" alt="Homography and Pose Estimation"/>
</p>

### Underwater Buoy Detection
---------------------------------------
This project proposes a perception system to detect a red, yellow and green underwater buoy based on experiments with a 1D Gaussian, single 3D Multivariate Gaussian and a GMM[Gaussian Mixture Model] to robustly detect these buoys.
<p align="center">
  <img src="https://github.com/rishabh1b/RoboticsPerception/blob/master/gifs/buoyDetection.gif?raw=true" alt="Homography and Pose Estimation"/>
</p>

### Lane Detection
---------------------------------------
This was a project in computer vision to efficiently detect lanes and develop a lane change alerting system based on visual feedback.
<p align="center">
  <img src="https://github.com/rishabh1b/RoboticsPerception/blob/master/gifs/laneDetection.gif?raw=true" alt="Homography and Pose Estimation"/>
</p>

### Traffic Sign Recognition
---------------------------------------
In this project an attempt was made to effectively recognize and classify traffic signs from a real-world data set. 
The first step is to segment out the region of interests. A combination of MSER and color thresholding is applied at this point of time to get the blue and signs region. 
A HOG-SVM based claasification was used. For detecting HOG features and MSER vl_feat library is used. The binary package can be downloaded from here - http://www.vlfeat.org/install-matlab.html. 
<p align="center">
  <img src="https://github.com/rishabh1b/RoboticsPerception/blob/master/gifs/tsr.gif?raw=true" alt="Homography and Pose Estimation"/>
</p>

### Car Tracking
---------------------------------------
This project focused on detection and tracking other cars for a self-driving car application
<p align="center">
  <img src="https://github.com/rishabh1b/RoboticsPerception/blob/master/gifs/carTracking.gif?raw=true" alt="Homography and Pose Estimation"/>
</p>

### Visual Odometry
---------------------------------------
This project focused on tracking the vehicle's position based on visual feedback.
<p align="center">
  <img src="https://github.com/rishabh1b/RoboticsPerception/blob/master/gifs/visualodom.gif?raw=true" alt="Homography and Pose Estimation"/>
</p>

Reports detailing the pipeline used for all these projects can be found [here](https://github.com/rishabh1b/RoboticsPerception/tree/master/Reports).
