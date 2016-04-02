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

    var levelSequence:[WKInterfaceButton] = []
    var userInputSequence:[WKInterfaceButton] = []

    var timer:NSTimer!

    var gameTilesCount=3
    var gameSpeed:NSTimeInterval = 1.0;
    var currentAnimatingTileIndex = 0
    var level = 1
    
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
        
	
        delay(1.2) { () -> () in
            self.animateWithDuration(0.4, animations: { () -> Void in
                self.gameTilesUIGroup.setHidden(false)
            },completion:  { () -> Void in
                self.showLevelTitle()
            } )

        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    //MARK: LOGIC
    
    func showLevelTitle() {
        self.topTitleLabel.setText("LEVEL \(self.level)")
        self.topTitleLabel.setTextColor(UIColor.whiteColor())
        
        self.animateWithDuration(0.3, animations: { () -> Void in
            self.topTitleLabel.setHidden(false)
            }, completion: { () -> Void in
                delay(1.0, closure: { () -> () in
                    self.animateWithDuration(0.3, animations: { () -> Void in
                        self.topTitleLabel.setHidden(true)
                        }, completion: { () -> Void in
                            
                            self.makeSequence()
                            
                    })
                })
        })
    }
    
    func makeSequence() {
        self.userInputSequence.removeAll()
        self.levelSequence.removeAll()
        self.userInputActivated = false
        self.currentAnimatingTileIndex = 0
        self.topTitleLabel.setHidden(true)

        var tilesAdded = 0
        let array = [self.button1,self.button2,self.button3,self.button4]
        
        while (tilesAdded < gameTilesCount) {
            let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
            let ele = array[randomIndex];

            if let last = self.levelSequence.last {
                if last != ele {
                    self.levelSequence.append(ele)
                    tilesAdded++
                }
            }
            else {
                self.levelSequence.append(ele)
                tilesAdded++
            }
        }

        self.animate()
    }
    
    func animate() {
        if currentAnimatingTileIndex < gameTilesCount {
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
                            // user tapping start
                            self.userInputActivated = true
                    })
                })
            })
        }
       
    }
    
    
    func reset() {
        self.animateWithDuration(0.5,animations:  { () -> Void in
                self.button1.setAlpha(1)
                self.button2.setAlpha(1)
                self.button3.setAlpha(1)
                self.button4.setAlpha(1)
            }, completion:  {
                () -> Void in
                self.animate()
            })
    }
    
    
    func checkIsUserSeqCompleted() {
        if userInputSequence.count == levelSequence.count {
            
            var success = true;
            for i in 0..<levelSequence.count {
                let levelSeqButton = levelSequence[i]
                let userSeqButton = self.userInputSequence[i]
                if levelSeqButton != userSeqButton {
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
