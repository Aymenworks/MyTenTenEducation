//
//  ViewController.swift
//  MyTenTenEducation
//
//  Created by Aymen Rebouh on 2018/04/18.
//  Copyright © 2018 Aymen Rebouh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Properties
    
    var viewModel = HomeViewModel()
    var fingerPosition: CGPoint?
    var cellSnapshotView: UIView?
    var cellSourceIndex: Int?

    /**
     What is CADisplayLink ? Why am I using it ?
     Everytime the finger is near the left or right edge, we scroll.
     But how to make a smooth scrolling ?
     The advantage of CADisplayLink is that it's a timer that allows to synchronize
     drawing to the refresh rate of the device. So no laggy or freezy effects.
     */
    var scrollTimer: CADisplayLink?
    
    @IBOutlet weak var smileyImageView: UIImageView!
    @IBOutlet weak var instructionsCollectionView: UICollectionView! {
        didSet {
            let instructionCell = UINib(nibName: String(describing: InstructionCollectionViewCell.self), bundle: nil)
            instructionsCollectionView.register(instructionCell, forCellWithReuseIdentifier: String(describing: InstructionCollectionViewCell.self))
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDragAndDropForInstructionsList()
    }
    
    // MARK: User Interaction
    
    @IBAction func execute(_ sender: Any) {
        do {
            try viewModel.execute(someInstructions: viewModel.instructions)
            smileyImageView.image = #imageLiteral(resourceName: "happy")
        } catch {
            print(error)
            smileyImageView.image = #imageLiteral(resourceName: "crying")
        }
    }
    
    @IBAction func clearInstructions(_ sender: Any) {
        viewModel.instructions.removeAll()
        viewModel.functions.removeAll()
        instructionsCollectionView.reloadData()
        smileyImageView.image = #imageLiteral(resourceName: "suspicious")
    }
    
    @IBAction func addInstruction(_ sender: RoundedButton) {
        let lastIndexPath = IndexPath(row: viewModel.instructions.isEmpty ? 0 : viewModel.instructions.count-1, section: 0)
        guard let instruction = Instruction(fromTag: sender.tag) else { return }
        
        switch instruction {
        case .mult:
            let instruction = Instruction.mult
            viewModel.instructions.insert(instruction, at: 0)
            instructionsCollectionView.reloadData()
            instructionsCollectionView.scrollToItem(at: lastIndexPath, at: .top, animated: true)
        case .print:
            let instruction = Instruction.print
            viewModel.instructions.insert(instruction, at: 0)
            instructionsCollectionView.reloadData()
            instructionsCollectionView.scrollToItem(at: lastIndexPath, at: .top, animated: true)
        case .ret:
            let instruction = Instruction.ret
            viewModel.instructions.insert(instruction, at: 0)
            instructionsCollectionView.reloadData()
            instructionsCollectionView.scrollToItem(at: lastIndexPath, at: .top, animated: true)
        case .push(_):
            showPopup(withTitle: "Enter a number to push", textFieldPlaceholder: "Number") { [weak self] alert in
                guard let _self = self else { return }
                if let text = alert.textFields?.first?.text, let number = Int(text) {
                    let instruction = Instruction.push(number)
                    _self.viewModel.instructions.insert(instruction, at: 0)
                    _self.instructionsCollectionView.reloadData()
                    _self.instructionsCollectionView.scrollToItem(at: lastIndexPath, at: .top, animated: true)
                }
            }
        case .call(_):
            showPopup(withTitle: "Enter a function to call", textFieldPlaceholder: "Function name") { [weak self] alert in
                guard let _self = self else { return }
                if let text = alert.textFields?.first?.text {
                    let instruction = Instruction.call(text)
                    _self.viewModel.instructions.insert(instruction, at: 0)
                    _self.instructionsCollectionView.reloadData()
                    _self.instructionsCollectionView.scrollToItem(at: lastIndexPath, at: .top, animated: true)
                }
            }
        case .function(_):
            showPopup(withTitle: "Enter a function to create", textFieldPlaceholder: "Function name") { [weak self] alert in
                guard let _self = self else { return }
                if let functionName = alert.textFields?.first?.text {
                    let instruction = Instruction.function(functionName)
                    _self.viewModel.instructions.insert(instruction, at: 0)
                    _self.instructionsCollectionView.reloadData()
                    _self.instructionsCollectionView.scrollToItem(at: lastIndexPath, at: .top, animated: true)
                }
            }
        }
    }
    
    func showPopup(withTitle title: String, textFieldPlaceholder: String, doneCompletionHandler: @escaping ((UIAlertController) -> ())) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = textFieldPlaceholder
            textfield.keyboardType = .namePhonePad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            doneCompletionHandler(alert)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func startTimer() {
        scrollTimer = CADisplayLink(target: self, selector: #selector(followUserDirectionScroll))
        scrollTimer?.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    func stopTimer() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    @objc func followUserDirectionScroll() {
        guard let position = self.fingerPosition else { return }

        // if the user finger is near the bottom edge of the collection view
        if position.y > instructionsCollectionView.convert(CGPoint(x: 0, y: instructionsCollectionView.bounds.maxY), to: view).y - 50 && position.y < instructionsCollectionView.convert(CGPoint(x: 0, y: instructionsCollectionView.contentSize.height), to: view).y {
            
            self.instructionsCollectionView.contentOffset.y = min(self.instructionsCollectionView.contentOffset.y + 5, instructionsCollectionView.convert(CGPoint(x: 0, y: instructionsCollectionView.contentSize.height), to: view).y)
            
            // else if the user finger is near the top edge
        } else if position.y < instructionsCollectionView.convert(CGPoint(x: 0, y: instructionsCollectionView.bounds.minY), to: view).y + 50  && self.instructionsCollectionView.contentOffset.y > 0 {
            self.instructionsCollectionView.contentOffset.y = max(0, self.instructionsCollectionView.contentOffset.y - 5)
        }
    }
    
    func customSnapshotOf(cell: UIView) {
        cellSnapshotView = cell.snapshotView(afterScreenUpdates: true)
        cellSnapshotView?.backgroundColor = UIColor.white
        cellSnapshotView?.transform = CGAffineTransform(rotationAngle: -3 * .pi / 180)
        cellSnapshotView?.alpha = 0.0
    }
    
    @objc func handleDragAndDrop(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: instructionsCollectionView)
        
        switch gesture.state {
            
        case .began:
            
            // We drag one snapshot at once
            guard cellSnapshotView == nil else { return }
            
            startTimer()
            
            // We check that we drag a cell
            guard let indexPath = instructionsCollectionView.indexPathForItem(at: location),
                let cell = instructionsCollectionView.cellForItem(at: indexPath) as? InstructionCollectionViewCell else { return }
            
            cellSourceIndex = indexPath.row
            
            customSnapshotOf(cell: cell)
            
            let locationInView = cell.convert(cell.center, to: view)
            
            UIView.animate(withDuration: 0.3) {
                self.cellSnapshotView?.alpha = 0.6
                self.cellSnapshotView?.center = locationInView
                cell.mode = .placeholder
            }
            
            view.addSubview(cellSnapshotView!)
            
        case .changed:
            
            // We handle the finger/cell moves only if the snapshot is displayed
            guard let snapshot = cellSnapshotView else { return }
            
            let locationInView = instructionsCollectionView.convert(gesture.location(in: instructionsCollectionView), to: view)
            
            self.fingerPosition = locationInView

            // We moves the snapshots as the user moves his finger
            snapshot.center = locationInView
            
            
            // If the destination index path exists and is different from the source, we swip cells
            if let indexPath = instructionsCollectionView.indexPathForItem(at: location), cellSourceIndex! != indexPath.row {
                let previousInstruction = viewModel.instructions[cellSourceIndex!]
                viewModel.instructions[cellSourceIndex!] = viewModel.instructions[indexPath.row]
                viewModel.instructions[indexPath.row] = previousInstruction
                instructionsCollectionView.moveItem(at: IndexPath(row: cellSourceIndex!, section: 0), to: indexPath)
                cellSourceIndex = indexPath.row
            }
            
        default:
            stopTimer()
            self.fingerPosition = nil

            // If the table view is empty, and we drag nothing and then drop nothing, the default state is called. So we exit early.
            guard cellSnapshotView != nil else { return }
            
            let indexPath = instructionsCollectionView.indexPathForItem(at: location)
            var cell: InstructionCollectionViewCell?
            
            // If we are outside the table view, we delete the snapshot to the last cell
            if indexPath == nil {
                viewModel.instructions.remove(at: cellSourceIndex!)
                instructionsCollectionView.deleteItems(at: [IndexPath(row: cellSourceIndex!, section: 0)])
                
            // Else if we are inside the table view, we just drop at the current index path
            } else {
                cell = instructionsCollectionView.cellForItem(at: indexPath!) as? InstructionCollectionViewCell
            }
            
            let locationInView = instructionsCollectionView.convert(gesture.location(in: instructionsCollectionView), to: view)
            
            // We drop the cell at its place
            UIView.animate(withDuration: 0.3, animations: {
                self.cellSnapshotView?.center = locationInView
                self.cellSnapshotView?.alpha = 0.0
                cell?.mode = .normal
                
            }) { _ in
                self.cellSnapshotView?.removeFromSuperview()
                self.cellSnapshotView = nil
                self.cellSourceIndex = nil
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout -

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let instruction = viewModel.instructions[indexPath.row]
        
        if instruction.isADeclaration {
            return CGSize(width: collectionView.bounds.width, height: 120)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func setupDragAndDropForInstructionsList() {
        let dragGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleDragAndDrop(gesture:)))
        dragGesture.minimumPressDuration = 0.3
        instructionsCollectionView.addGestureRecognizer(dragGesture)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: InstructionCollectionViewCell.self), for: indexPath) as! InstructionCollectionViewCell
        cell.mode = .normal
        
        let instruction = viewModel.instructions[indexPath.row]
        cell.setup(withInstruction: instruction)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.instructions.count
    }
}
