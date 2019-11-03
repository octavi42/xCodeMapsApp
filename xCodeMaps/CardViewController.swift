import UIKit

class CardViewController: UIView {

    @IBOutlet var navigationBar: UIView!
    @IBOutlet var directionButtonOutlet: UIButton!
    
    @IBAction func directionButton(_ sender: Any) {
//        directionButtonOutlet.setImage(UIImage(named: "navigationBarDirectionButtonBlue")?.withRenderingMode(.alwaysOriginal), for: .normal)
        MapViewController().directionToPin()
        MapViewController().printSomething()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("CardViewController", owner: self, options: nil)
        addSubview(navigationBar)
        navigationBar.frame = self.bounds
        navigationBar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
