// CountedSetTests.swift
// Copyright (c) 2014 Nate Cook, licensed under the MIT License

import UIKit
import XCTest


// MARK: - Tests


class CountedSetTests: XCTestCase {
	
	func testOriginalTests() {
		let vowelSet = CountedSet("aeiou")
		let alphabetSet : CountedSet<Character> = CountedSet(elements: "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
		let emptySet = CountedSet<Int>()
		
		XCTAssert(vowelSet.isSubsetOfSet(alphabetSet) == true)
		XCTAssert(vowelSet.isSupersetOfSet(alphabetSet) == false)
		XCTAssert(alphabetSet.isSupersetOfSet(vowelSet) == true)
		XCTAssert(emptySet.isEmpty)
		XCTAssert(vowelSet.count == 5)
		XCTAssert(vowelSet.contains("b") == false)
		
		var mutableVowelSet = vowelSet
		mutableVowelSet.add("a")
		XCTAssert(mutableVowelSet.count == 5)
		mutableVowelSet += "y"
		XCTAssert(mutableVowelSet.count == 6)
		mutableVowelSet += CountedSet(elements: "å","á","â","ä","à","é","ê","è","ë","í","î","ï","ì","ø","ó","ô","ö","ò","ú","û","ü","ù")
		
		XCTAssert(mutableVowelSet.intersectsWithSet(alphabetSet) == true)
		XCTAssert(mutableVowelSet.isSubsetOfSet(alphabetSet) == false)
		var newLetterSet = alphabetSet.setByIntersectionWithSet(mutableVowelSet)
		newLetterSet.remove("y")
		XCTAssert(newLetterSet == vowelSet)
		
		let bracketedLetterSet = vowelSet.map { "[\($0)]" }
		XCTAssert(bracketedLetterSet.contains("[a]") == true)
		
		var vowelCount = 0
		var vowelIndex = vowelSet.startIndex
		do {
			++vowelCount
			vowelIndex = vowelIndex.successor()
		} while vowelIndex != vowelSet.endIndex
		XCTAssert(vowelCount == 5)
		XCTAssert(emptySet.startIndex == emptySet.endIndex)
		
		println()
		println("All tests passed.")
		println()
	}
	
	func testTiming() {
		func timeBlock(block: () -> Int) -> (Int, NSTimeInterval) {
			let start = NSDate()
			let result = block()
			return (result, NSDate().timeIntervalSinceDate(start))
		}
		
		var timedSet = CountedSet<Int>()
		var timedArray = Array<Int>()
		let timedSize = 1_000
		
		let (setCreatedCount, setCreatedTime) = timeBlock {
			for _ in 1...timedSize {
				let num = Int(arc4random_uniform(UInt32(timedSize)))
				timedSet.add(num)
			}
			return timedSet.count
		}
		println("CountedSet added \(setCreatedCount) unique elements in \(setCreatedTime).")
		
		let (setMatchedCount, setMatchedTime) = timeBlock {
			var matchCount = 0
			for _ in 1...timedSize {
				let num = Int(arc4random_uniform(UInt32(timedSize)))
				if timedSet.contains(num) {
					++matchCount
				}
			}
			return matchCount
		}
		println("CountedSet matched \(setMatchedCount) times out of \(timedSize) in \(setMatchedTime).")
		
		let (arrayCreatedCount, arrayCreatedTime) = timeBlock {
			for _ in 1...timedSize {
				let num = Int(arc4random_uniform(UInt32(timedSize)))
				timedArray.append(num)
			}
			return timedArray.count
		}
		println("Array added \(arrayCreatedCount) elements in \(arrayCreatedTime).")
		
		let (arrayMatchedCount, arrayMatchedTime) = timeBlock {
			var matchCount = 0
			for _ in 1...timedSize {
				let num = Int(arc4random_uniform(UInt32(timedSize)))
				if contains(timedArray, num) {
					++matchCount
				}
			}
			return matchCount
		}
		println("Array matched \(arrayMatchedCount) times out of \(timedSize) in \(arrayMatchedTime).")
		
		println()
		println("Array \(Int(setCreatedTime / arrayCreatedTime))x faster at creation than CountedSet.")
		println("CountedSet \(Int(arrayMatchedTime / setMatchedTime))x faster at lookup than Array.")
		
		
		/*
		CountedSet added 634 unique elements in 0.0123220086097717.
		CountedSet matched 653 times out of 1000 in 0.00595200061798096.
		Array added 1000 elements in 0.00509095191955566.
		Array matched 625 times out of 1000 in 1.80631500482559.
		
		Array 2x faster at creation than CountedSet.
		CountedSet 303x faster at lookup than Array.
		
		
		Set added 644 unique elements in 0.0131829977035522.
		Set matched 661 times out of 1000 in 0.00484997034072876.
		Array added 1000 elements in 0.00488603115081787.
		Array matched 611 times out of 1000 in 1.76686799526215.
		
		Array 2x faster at creation than Set.
		Set 364x faster at lookup than Array.
		*/
		
		/*
		Set added 637 unique elements in 1.2172309756279.
		Set matched 650 elements out of 1000 in 0.00271201133728027.
		Array added 1000 elements in 0.00527894496917725.
		Array matched 612 elements out of 1000 in 2.09512096643448.
		
		Array 230x faster at creation than Set.
		Set 772x faster at lookup than Array.
		*/
		
		let setSize = 100_000
		var bigSet = CountedSet(1...setSize)
		let anotherBigSet = CountedSet(1...setSize)
		let setEquality = { () -> Int in
			return bigSet == anotherBigSet ? 1 : 0
		}
		
		let (equalComparison, equalComparisonTime) = timeBlock(setEquality)
		bigSet.remove(setSize)
		let (offsetComparison, offsetComparisonTime) = timeBlock(setEquality)
		bigSet.add(setSize + 1)
		let (unequalComparison, unequalComparisonTime) = timeBlock(setEquality)
		
		println()
		println("Checked equality (\(equalComparison == 1)) on equal big sets in \(equalComparisonTime)")
		println("Checked equality (\(offsetComparison == 1)) on different-size big sets in \(offsetComparisonTime)")
		println("Checked equality (\(unequalComparison == 1)) on same-size unequal big sets in \(unequalComparisonTime)")
		
		/*
		Checked equality (true) on equal big sets in 0.97138899564743
		Checked equality (false) on different-size big sets in 3.03983688354492e-06
		Checked equality (false) on same-size unequal big sets in 0.678294956684113
		
		Checked equality (true) on equal big sets in 0.935158014297485
		Checked equality (false) on different-size big sets in 2.02655792236328e-06
		Checked equality (false) on same-size unequal big sets in 0.629329025745392
		*/
		
		/*
		Checked equality (true) on equal big sets in 0.923960983753204
		Checked equality (false) on different-size big sets in 2.98023223876953e-06
		Checked equality (false) on same-size unequal big sets in 0.908538997173309
		*/
	}
	
	func testAnyObject() {
		var emptySet : CountedSet<String> = CountedSet<String>()
		XCTAssert(emptySet.anyElement() == nil)
		emptySet += "a"
		XCTAssert(emptySet.anyElement() == "a")
	}
}


// MARK: - Timing
