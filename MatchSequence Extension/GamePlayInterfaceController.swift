//
//  InterfaceController.swift
//  MatchSequence Extension
//
//  Created by Shubhank on 29/03/16.
//  Copyright © 2016 com. All rights reserved.
//

import WatchKit
import Foundation


class GamePlayInterfaceController: WKInterfaceController {

    @IBOutlet var gameTilesUIGroup: WKInterfaceGroup!
    @IBOutlet var button1: WKInterfaceButton!
    @IBOutlet var button2: WKInterfaceButton!
    @IBOutlet var button3: WKInterfaceButton!
    @IBOutlet var button4: WKInterfaceButton!
    

    @IBOutlet var topTitleLabel: WKInterfaceLabel!

    // Contains the sequence of buttons of the level
    var levelSequence:[WKInterfaceButton] = []
    
    // contains the user inputted sequence of buttons
    var userInputSequence:[WKInterfaceButton] = []

    // number of tiles in the sequence.. incremented on every level completed
    var gameTilesCount=3
    
    // speed by which tiles animation show. decrements on each level completed
    var gameSpeed:NSTimeInterval = 1.0;
    
    // index of the level sequence to animate
    var currentAnimatingTileIndex = 0
    
    // to show on top title label
    var level = 1
    
    // dont take user input till the sequence animation has been done
    var userInputActivated = false
    
    //MARK: LIFE CYCLE METHODS
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didAppear() {
        super.didAppear()
        
        self.showLevelTitle()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    //MARK: LOGIC
    func showLevelTitle() {
        self.topTitleLabel.setText("LEVEL \(self.level)")
        self.topTitleLabel.setTextColor(UIColor.whiteColor())
        
        // animate the level title
        self.animateWithDuration(0.3, animations: { () -> Void in
                self.topTitleLabel.setHidden(false)
            }, completion: { () -> Void in
                // hide the label after delay
                delay(1.0, closure: { () -> () in
                    self.animateWithDuration(0.3, animations: { () -> Void in
                        self.topTitleLabel.setHidden(true)
                        }, completion: { () -> Void in
                            // start the sequence
                            self.makeSequence()
                            
                    })
                })
        })
    }
    
    
    /* 
    / GENERATES THE RANDOM LEVEL SEQUENCE
    */
    func makeSequence() {
        self.userInputSequence.removeAll()
        self.levelSequence.removeAll()
        self.userInputActivated = false
        self.currentAnimatingTileIndex = 0
        self.topTitleLabel.setHidden(true)

        var tilesAdded = 0
        let array = [self.button1,self.button2,self.button3,self.button4]
        
        while (tilesAdded < gameTilesCount) {
            // get random button from all the tiles
            let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
            let ele = array[randomIndex];

            if let last = self.levelSequence.last {
                if last != ele {
                    // if the random element isnt the last tile that was added. that is not two in a row.. add it to the sequence
                    self.levelSequence.append(ele)
                    tilesAdded++
                }
            }
            else {
                // if this is the first element. simply add to the seqeuence
                self.levelSequence.append(ele)
                tilesAdded++
            }
        }

        self.animate()
    }
    
    func animate() {
        if currentAnimatingTileIndex < gameTilesCount {
            // animate all buttons in the level sequence
            let button = self.levelSequence[currentAnimatingTileIndex]
            
            self.animateWithDuration(self.gameSpeed , animations: { () -> Void in
                button.setAlpha(0)
                
                }, completion: { () -> Void in
                    self.animateWithDuration(self.gameSpeed , animations: { () -> Void in
                        button.setAlpha(1)
                        
                        }, completion: { () -> Void in
                            self.currentAnimatingTileIndex++
                            self.animate()
                    })
            })

        }
        else {
            // start user game counter
            userInputSequence.removeAll()
            self.topTitleLabel.setText("GO")
            self.topTitleLabel.setTextColor(UIColor.whiteColor())
            
            self.animateWithDuration(0.3, animations: { () -> Void in
                self.topTitleLabel.setHidden(false)
            }, completion: { () -> Void in
                delay(1.0, closure: { () -> () in
                    self.animateWithDuration(0.3, animations: { () -> Void in
                        self.topTitleLabel.setHidden(true)
                        }, completion: { () -> Void in
                            // user tapping start... game start
                            self.userInputActivated = true
                    })
                })
            })
        }
       
    }
    
   
    func checkIsUserSeqCompleted() {
        // same number of taps completed as in the level sequence
        if userInputSequence.count == levelSequence.count {
            
            var success = true;
            
            for i in 0..<levelSequence.count {
                let levelSeqButton = levelSequence[i]
                let userSeqButton = self.userInputSequence[i]
                if levelSeqButton != userSeqButton {
                    // the user didnt tap the correct sequence button for this index
                    success = false
                    break
                }
            }
            
            
            self.showGameEnd_WithSuccess(success)
        }
    }
 
    
    func showGameEnd_WithSuccess(let success:Bool) {
        let title = success ? "MATCH" : "FAIL"
        let color = success ? UIColor.greenColor() : UIColor.redColor()
        self.topTitleLabel.setText(title)
        self.topTitleLabel.setTextColor(color)

        self.animateWithDuration(0.3, animations: { () -> Void in
            self.topTitleLabel.setHidden(false)
            }, completion: { () -> Void in
                delay(1.2, closure: { () -> () in
                    if success {
                        // if success increment the level and decrease tiles animation speed
                        self.gameTilesCount++
                        self.level++
                        self.gameSpeed = self.gameSpeed - 0.1
                    }
                    self.showLevelTitle()
                })
        })
    }
    
    
    //MARK: USER INPUT METHODS
    @IBAction func button1_tapped() {
        if self.userInputActivated {
            self.userInputSequence.append(self.button1)
            self.checkIsUserSeqCompleted()
        }
    }
    
    @IBAction func button2_tapped() {
        if self.userInputActivated {
            self.userInputSequence.append(self.button2)
            self.checkIsUserSeqCompleted()
        }
    }
    
    @IBAction func button3_tapped() {
        if self.userInputActivated {
            self.userInputSequence.append(self.button3)
            self.checkIsUserSeqCompleted()
        }
    }
    
    @IBAction func button4_tapped() {
        if self.userInputActivated {
            self.userInputSequence.append(self.button4)
            self.checkIsUserSeqCompleted()
        }
    }

}
