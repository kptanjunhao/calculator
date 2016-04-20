//
//  LongNumOperation.swift
//  calcular
//
//  Created by 谭钧豪 on 16/4/20.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

import Foundation
//大数加法Long Number Plus Method
infix operator ++{
associativity left precedence 140
}
func ++(left:String,right:String) -> String{
    var resultstr = String()
    
    var leftstr = [String]()
    var rightstr = [String]()
    //将数字分割成小数部分以及整数部分
    //Separated the number into decimal part and integer part
    if left.containsString("."){
        leftstr = left.componentsSeparatedByString(".")
    }else{
        leftstr = [left]
    }
    if right.containsString("."){
        rightstr = right.componentsSeparatedByString(".")
    }else{
        rightstr = [right]
    }
    //处理小数部分    Deal the decimal number.
    //小数状态0代表左右都有小数部分，1代表左边有小数右边没，2代表右边有小数左边没，3代表两边都没有小数
    /**
     *  0:Either left number and right number both have the decimal part
     *  1:Only left number has the decimal part
     *  2:Only right number has the decimal part
     *  3:Both sides do not have the decimal part.
     */
    let decimalStatu = leftstr.count == 2 && rightstr.count == 2 ? 0 : (leftstr.count == 1 && rightstr.count == 1 ? 3 : leftstr.count == 2 && rightstr.count != 2 ? 1 : 2)
    var decimalCanPlus1 = false//The value show the decimal part will full to integer part.一个显示小数位相加后是否可以使整数加1的状态值
    switch decimalStatu {
    case 0:
        resultstr.appendContentsOf(".")
        let leftIsLonger = leftstr[1] > rightstr[1]
        var pstrlong = [Int]()
        var pstrshort = [Int]()
        for char in (leftIsLonger ? leftstr[1] : rightstr[1]).characters{
            pstrlong.insert(Int(String(char))!, atIndex: 0)
        }
        for char in (!leftIsLonger ? leftstr[1] : rightstr[1]).characters{
            pstrshort.insert(Int(String(char))!, atIndex: 0)
        }
        for index in pstrshort.count..<pstrlong.count{
            resultstr.insert(Character(String(pstrlong[index])), atIndex: resultstr.startIndex.advancedBy(1))
        }
        for index in 0..<pstrshort.count{
            //如果小数可以进位，则末位加1.只加一次
            //If decimal part can full to integer part,integer last number plus 1,only plus once.
            var curResult = pstrlong[index] + pstrshort[index] + (decimalCanPlus1 ? 1 : 0)
            if curResult >= 10{
                curResult -= 10
                decimalCanPlus1 = true
            }else{
                decimalCanPlus1 = false
            }
            resultstr.insert(Character(String(curResult)), atIndex: resultstr.startIndex.advancedBy(1))
        }
        
    case 1:
        resultstr.appendContentsOf(".")
        for curNum in leftstr[1].characters{
            resultstr.append(curNum)
        }
    case 2:
        resultstr.appendContentsOf(".")
        for curNum in rightstr[1].characters{
            resultstr.append(curNum)
        }
    case 3:
        break
    default:
        fatalError("decimalStatu can not detect two numbers statu")
    }
    //处理整数部分    Deal with the integer part
    var leftarray = [Int]()
    for char in leftstr[0].characters{
        leftarray.insert(Int(String(char))!, atIndex: 0)
    }
    var rightarray = [Int]()
    for char in rightstr[0].characters{
        rightarray.insert(Int(String(char))!, atIndex: 0)
    }
    //较短数的数位
    //The shorter number's count
    let minCount = leftarray.count>rightarray.count ? rightarray.count : leftarray.count
    //数字相加后是否会进十的状态值
    //After plusing , if the result greater than 10,this value turns true.
    var isGreaterThanTen = false
    for index in 0..<minCount{
        var curResult = leftarray[index] + rightarray[index] + (isGreaterThanTen ? 1 : 0) + (decimalCanPlus1 ? 1 : 0)
        isGreaterThanTen = curResult >= 10
        decimalCanPlus1 = false
        if isGreaterThanTen{curResult -= 10}
        resultstr.insert(Character(String(curResult)), atIndex: resultstr.startIndex)
    }
    //指定较长的数，来完成短数位后的运算
    //Continue calculate the value after finished the shortnumber dealing.
    let longArray = leftarray.count>rightarray.count ? leftarray : rightarray
    for index in minCount..<(longArray.count){
        var curResult = longArray[index]
        if isGreaterThanTen{
            curResult += 1
            isGreaterThanTen = curResult >= 10
            if isGreaterThanTen{
                curResult -= 10
            }
        }
        resultstr.insert(Character(String(curResult)), atIndex: resultstr.startIndex)
    }
    //如果计算完毕后，仍会进十，则在首位加1
    //if finished all the calculates,the result still can carrybit,then add 1 to the first position.
    if isGreaterThanTen{
        resultstr.insert("1", atIndex: resultstr.startIndex)
    }
    return resultstr
}

func *(left:String, right:String) -> String{
    var resultstr = String()
    //获取小数位数
    //get how many number of the decimal part.
    var leftCount = 0
    var rightCount = 0
    if let leftIndex = left.characters.indexOf("."){
        leftCount = leftIndex.distanceTo(left.endIndex) - 1
    }
    if let rightIndex = right.characters.indexOf("."){
        rightCount = rightIndex.distanceTo(right.endIndex) - 1
    }
    let pCount = leftCount + rightCount
    //移除小数点并添加到数组
    //remove the point(.) and add the number to array
    let leftStr = left.stringByReplacingOccurrencesOfString(".", withString: "")
    let rightStr = right.stringByReplacingOccurrencesOfString(".", withString: "")
    var longArray = [Int]()
    var shortArray = [Int]()
    let resultArray = NSMutableArray()
    for char in (leftStr.characters.count >= right.characters.count ? leftStr.characters : rightStr.characters){
        longArray.insert(Int(String(char))!, atIndex: 0)
    }
    for char in (leftStr.characters.count < right.characters.count ? leftStr.characters : rightStr.characters){
        shortArray.insert(Int(String(char))!, atIndex: 0)
    }
    //进行逐位乘法运算
    //multiply number one by one.Like 1,234 * 12 = 1,234 * 1 * 10 + 1,234 * 2
    for shortIndex in 0..<shortArray.count{
        var tempCarry = 0
        var tempArray = [Int]()
        var tempStr = ""
        //每位运算都在最后一位添加0
        //Add 0 to last position when calculating.Like 1,234 * 1 * 10 = 12,340 * 1
        for _ in 0..<shortIndex{
            tempArray.append(0)
            tempStr.insert(Character("0"), atIndex: tempStr.startIndex)
        }
        for longIndex in 0..<longArray.count{
            var curResult = shortArray[shortIndex] * longArray[longIndex] + tempCarry
            tempCarry = curResult/10
            curResult = curResult%10
            tempArray.append(curResult)
            tempStr.insert(Character("\(curResult)"), atIndex: tempStr.startIndex)
        }
        if tempCarry != 0{
            tempArray.append(tempCarry)
            tempStr.insert(Character("\(tempCarry)"), atIndex: tempStr.startIndex)
        }
        resultArray.addObject(tempStr)
    }
    //将乘法之后的结果相加起来
    //Add all the multiply result
    resultstr = resultArray[0] as! String
    for index in 1..<resultArray.count{
        resultstr = resultstr ++ (resultArray[index] as! String)
    }
    if pCount != 0{
        resultstr.insert(".", atIndex: resultstr.endIndex.advancedBy(-pCount))
    }
    
    
    return resultstr
}