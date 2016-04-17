//
//  ViewController.swift
//  calcular
//
//  Created by 谭钧豪 on 16/4/16.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableViewData: NSMutableArray!
    var tableView: UITableView!
    
    var numTF: UITextField!
    var symbolTF: UITextField!
    var lastNumTF: UITextField!
    
    var tempArray: NSMutableArray!
    var symbolArray: NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewData = NSMutableArray()
        
        
        let tableViewFrame = CGRectMake(0, 20, 150, self.view.frame.height)
        tableView = UITableView(frame: tableViewFrame, style: UITableViewStyle.Plain)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        numTF = UITextField(frame: CGRectMake(150,70,200,30))
        numTF.placeholder = "0"
        numTF.textAlignment = .Right
        self.view.addSubview(numTF)
        symbolTF = UITextField(frame: CGRectMake(150,50,200,30))
        symbolTF.textAlignment = .Right
        self.view.addSubview(symbolTF)
        lastNumTF = UITextField(frame: CGRectMake(150,30,200,30))
        lastNumTF.placeholder = "0"
        lastNumTF.textAlignment = .Right
        self.view.addSubview(lastNumTF)
        tempArray = NSMutableArray()
        symbolArray = NSMutableArray()
        
        addKeyboard(CGRectMake(150, 100, 200, 400))
    }
    
    func addKeyboard(keyboardFrame:CGRect){
        let keyboardView = UIView(frame: keyboardFrame)
        keyboardView.backgroundColor = UIColor.blackColor()
        let btnWidth = (keyboardFrame.width-2)/4
        let btnHeight = (keyboardFrame.height-2)/4
        // 1-9的数字视图添加
        for i in 0..<9{
            let curX = 1+CGFloat(i%3) * btnWidth
            let curY = 1+CGFloat((8-i)/3) * btnHeight
            let numViewFrame = CGRectMake(curX, curY, btnWidth - 1, btnHeight - 1)
            let numView = UIView(frame: numViewFrame)
            numView.tag = i+1
            let numLabel = UILabel(frame: CGRectMake(0,0,numViewFrame.width,numViewFrame.height))
            numLabel.text = "\(i+1)"
            numLabel.textColor = UIColor.blueColor()
            numLabel.textAlignment = .Center
            numView.addSubview(numLabel)
            numView.backgroundColor = UIColor.whiteColor()
            numView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.numTap(_:))))
            keyboardView.addSubview(numView)
        }
        // 0的视图添加
        let cur0X: CGFloat = 1
        let cur0Y = 1 + 3 * btnHeight
        let num0ViewFrame = CGRectMake(cur0X, cur0Y, btnWidth - 1, btnHeight - 1)
        let num0View = UIView(frame: num0ViewFrame)
        num0View.tag = 0
        let num0Label = UILabel(frame: CGRectMake(0,0,num0ViewFrame.width,num0ViewFrame.height))
        num0Label.text = "0"
        num0Label.textColor = UIColor.blueColor()
        num0Label.textAlignment = .Center
        num0View.addSubview(num0Label)
        num0View.backgroundColor = UIColor.whiteColor()
        num0View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.numTap(_:))))
        keyboardView.addSubview(num0View)
        // .的视图添加
        let curpX = 1 + btnWidth
        let curpY = 1 + 3 * btnHeight
        let numpViewFrame = CGRectMake(curpX, curpY, btnWidth - 1, btnHeight - 1)
        let numpView = UIView(frame: numpViewFrame)
        numpView.tag = -1
        let numpLabel = UILabel(frame: CGRectMake(0,0,numpViewFrame.width,numpViewFrame.height))
        numpLabel.text = "."
        numpLabel.textColor = UIColor.blueColor()
        numpLabel.textAlignment = .Center
        numpView.addSubview(numpLabel)
        numpView.backgroundColor = UIColor.whiteColor()
        numpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.numTap(_:))))
        keyboardView.addSubview(numpView)
        
        for i in 0..<4{
            var symbol = ""
            switch i{
                case 3:symbol = "➕"
                case 2:symbol = "➖"
                case 1:symbol = "✖️"
                case 0:symbol = "➗"
            default:symbol = ""
            }
            
            let symbolHeight = ((3*keyboardFrame.height/4)-2)/4
            let curX = 1 + 3*btnWidth
            let curY = 1 + CGFloat(i) * symbolHeight
            let symbolViewFrame = CGRectMake(curX, curY, btnWidth, symbolHeight - 1)
            let symbolBtn = UIButton(type: UIButtonType.System)
            symbolBtn.tag = i
            symbolBtn.backgroundColor = UIColor.whiteColor()
            symbolBtn.frame = symbolViewFrame
            symbolBtn.setTitle(symbol, forState: UIControlState.Normal)
            symbolBtn.addTarget(self, action: #selector(self.addNumToTemp(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            keyboardView.addSubview(symbolBtn)
        }
        let equalBtn = UIButton(frame: CGRectMake(1 + 3*btnWidth, 1 + 4 * ((3*keyboardFrame.height/4)-2)/4, btnWidth, btnHeight))
        equalBtn.setTitle("=", forState: UIControlState.Normal)
        equalBtn.backgroundColor = UIColor.whiteColor()
        equalBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        equalBtn.addTarget(self, action: #selector(self.calc), forControlEvents: UIControlEvents.TouchUpInside)
        keyboardView.addSubview(equalBtn)
        
        
        self.view.addSubview(keyboardView)
    }
    
    func numTap(sender:UITapGestureRecognizer){
        if sender.view!.tag != -1{
            numTF.text! += "\(sender.view!.tag)"
        }else{
            numTF.text! += "."
        }
    }
    
    func addNumToTemp(sender:UIButton){
        var num = Double()
        if let tempnum = Double.init(numTF.text!){
            num = tempnum
        }else{
            if tempArray.count != 0{
                symbolArray.removeLastObject()
                symbolArray.addObject(sender.tag)
            }
            return
        }
        tempArray.addObject(num)
        symbolArray.addObject(sender.tag)
        self.showSymbol(sender.tag)
        
        lastNumTF.placeholder = numTF.text
        numTF.placeholder = "0"
        numTF.text = nil
    }
    
    func showMSG(){
        print("------------------")
        print("数字：")
        print(tempArray)
        print("符号：")
        print(symbolArray)
    }
    
    func showSymbol(symbolCode:Int){
        var symbol = ""
        switch symbolCode{
        case 3:symbol = "➕"
        case 2:symbol = "➖"
        case 1:symbol = "✖️"
        case 0:symbol = "➗"
        default:symbol = ""
        }
        symbolTF.placeholder = symbol
    }
    
    func calc(){
        var num = Double()
        if let tempnum = Double.init(numTF.text!){
            num = tempnum
        }
        tempArray.addObject(Double(num))
        numTF.text = nil
        var arrayHasPrioritySymbol = false
        for symbol in symbolArray{
            let symbolInt = symbol.integerValue
            if symbolInt == 0 || symbolInt == 1{
                arrayHasPrioritySymbol = true
            }
        }
        if symbolArray.count != 0{
            if arrayHasPrioritySymbol{
                for symbol in symbolArray{
                    let symbolInt = symbol.integerValue
                    switch symbolInt {
                    case 0:
                        let index = symbolArray.indexOfObject(symbol)
                        let first = tempArray[index].doubleValue
                        let last = tempArray[index+1].doubleValue
                        tempArray[index] = first / last
                        tempArray.removeObjectAtIndex(index+1)
                        symbolArray.removeObjectAtIndex(index)
                        break
                    case 1:
                        let index = symbolArray.indexOfObject(symbol)
                        let first = tempArray[index].doubleValue
                        let last = tempArray[index+1].doubleValue
                        tempArray[index] = first * last
                        tempArray.removeObjectAtIndex(index+1)
                        symbolArray.removeObjectAtIndex(index)
                        break
                    default:
                        continue
                    }
                    self.showMSG()
                }
                calc()
            }else{
                for symbol in symbolArray{
                    let symbolInt = symbol.integerValue
                    switch symbolInt {
                    case 2:
                        let index = symbolArray.indexOfObject(symbol)
                        let first = tempArray[index].doubleValue
                        let last = tempArray[index+1].doubleValue
                        tempArray[index] = first - last
                        tempArray.removeObjectAtIndex(index+1)
                        symbolArray.removeObjectAtIndex(index)
                        break
                    case 3:
                        let index = symbolArray.indexOfObject(symbol)
                        let first = tempArray[index].doubleValue
                        let last = tempArray[index+1].doubleValue
                        tempArray[index] = first + last
                        tempArray.removeObjectAtIndex(index+1)
                        symbolArray.removeObjectAtIndex(index)
                        break
                    default:
                        continue
                    }
                    self.showMSG()
                }
                calc()
            }
        }else{
            numTF.text = "\(tempArray[0])"
            lastNumTF.text = ""
            symbolTF.text = ""
            tempArray.removeLastObject()
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

