import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var punctuation: UILabel!
    
    @IBOutlet weak var lives: UILabel!
    //Viper
    var viperImageView = UIImageView()
    var viper = Viper(speed: 3.5, center: CGPoint(x: 200, y: 600), size: CGSize(width: 100, height: 100))
    
    //Asteroids
    let ASTEROIDS_IMAGES_NAMES = ["Asteroid_A", "Asteroid_B", "Asteroid_C"]
    var asteroids = [Asteroid]()
    var asteroidsViews = [UIImageView]()
    var asteroidsToBeRemoved = [Asteroid]()
    
    
    //Game Logic
    var gameRunning = false //to control game state
    var stepNumber = 0 //Used in asteroids generation: every 5s an asteroid will be created
    var velocity: Float = 5
    var upPunctuation = 1
    var setPuntuaction = 0
    var removeLive = 1
    var remainingLives = 3
    var detector = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set up Viper
        viperImageView.frame.size = viper.size
        viperImageView.center = viper.center
        viperImageView.image = UIImage(named: "viper")
        self.view.addSubview(viperImageView)
        
        //allow user tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        self.view.addGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = true
        
        //set game running
        self.gameRunning = true
        
        //initialize timer
        let dislayLink = CADisplayLink(target: self, selector: #selector(self.updateScene))
        dislayLink.add(to: .current, forMode: .default)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended {
            let tapPoint = sender.location(in: self.view)
            //update the model
            self.viper.moveToPoint = tapPoint
        }
    }
    
    @objc func updateScene(){
        if gameRunning{
            //create an asterior every 5s
            if (stepNumber%Int((60*velocity))==0 && stepNumber != 0){
                
                createAsteroid()
                if (velocity <= 5 && velocity > 0.8){
                    velocity = velocity - 0.1
                    upPunctuation = upPunctuation + 2
                }

            }
            stepNumber+=1
            
            //update location viper
            self.viper.step() //update the model
            self.viperImageView.center = self.viper.center //update the view from the model
            
            //update location asteroids
            for index in 0..<asteroids.count{
                asteroids[index].step()
                asteroidsViews[index].center = asteroids[index].center
            }
            
            //check viper screen collision
            
            if viper.checkScreenCollision(screenViewSize: UIScreen.main.bounds.size){
                remainingLives = 0
                lives.text = "\(remainingLives)"
                
            }
            
            if(remainingLives == 2){
                viperImageView.alpha = 0.7
            }else if remainingLives == 1{
                viperImageView.alpha = 0.5
            }else if remainingLives == 0{
                viperImageView.alpha = 0
            }
            
            //check asteroids collision between viper and screen
            for actor in asteroids{
                if viper.overlapsWith(actor: actor) && detector == true{
                    remainingLives = remainingLives - removeLive
                    lives.text = "\(remainingLives)"
                    detector = false
                    setPuntuaction = setPuntuaction - 24
                    punctuation.text = "\(setPuntuaction)"
                }else if !viper.overlapsWith(actor: actor){
                    detector = true
                }
            }
            
            //remove from scene asteroids
            /*for actor in asteroids{
                if actor.checkScreenCollision(screenViewSize: UIScreen.main.bounds.size){
                    for index in 0..<asteroids.count{
                        asteroidsViews.remove(at: index)
                        asteroidsToBeRemoved.remove(at: index)
                    }
                    
                }
            }*/
        }
    }
    
    private func createAsteroid(){
        let screenSize: Float = Float(UIScreen.main.bounds.width - 50)
        let sizeX = Int.random(in: 20...100)
        let sizeY = Int.random(in: 20...100)
        let positionX = Float.random(in : 0...(screenSize))
        
        let asteroid = Asteroid(speed: 3, center: CGPoint(x: Int(positionX), y: 50), size: CGSize(width: sizeX, height: sizeY))
        self.asteroids.append(asteroid)
        
        let index = Int.random(in: 0 ..< ASTEROIDS_IMAGES_NAMES.count)
        let asteroidView = UIImageView(image: UIImage(named: ASTEROIDS_IMAGES_NAMES[index]))
        asteroidView.frame.size = asteroid.size
        asteroidView.center = asteroid.center
        self.view.addSubview(asteroidView)
        self.asteroidsViews.append(asteroidView)
        asteroidsToBeRemoved = asteroids
        //La puntuacion es determinada por un valor por defecto, mas la suma de unos puntos que iran incrementando a la vez que la velocidad de generacion de los meteoritos.
        setPuntuaction = setPuntuaction + Int((10 + upPunctuation))
        punctuation.text = "\(setPuntuaction)"
    }
    
    
}

