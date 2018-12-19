import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    let buttonView = UIButton(type: .custom)
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.view.backgroundColor = .blue   

        buttonView.rx.tap.subscribe().disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        
        Observable.just("Hello World")
            .delay(2.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.showUpAlert(text)
            }).disposed(by: disposeBag)
    }

    func showUpAlert(_ text: String) {

        let vc = UIAlertController.init(title: text, message: nil, preferredStyle: .alert)
        vc.addAction(.init(title: "OK", style: .cancel, handler: nil))
        self.present(vc, animated: true, completion: nil)
    }
}

