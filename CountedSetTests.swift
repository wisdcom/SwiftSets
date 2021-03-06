// CountedSetTests.swift
// Copyright (c) 2014 Nate Cook, licensed under the MIT License

import UIKit
import XCTest


// MARK: - Tests


class CountedSetTests: XCTestCase {
	
	func testOriginalTests() {
		let vowelSet : CountedSet<Character> = CountedSet(elements: "a", "e", "i", "o", "u")
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
		
		// for the "counted" part of CountedSet
		XCTAssert(mutableVowelSet.countForElement("i") == 1)
		mutableVowelSet.add("i")
		XCTAssert(mutableVowelSet.countForElement("i") == 2)
		mutableVowelSet.add("i")
		XCTAssert(mutableVowelSet.countForElement("i") == 3)
		_ = mutableVowelSet.remove("i")
		XCTAssert(mutableVowelSet.countForElement("i") == 2)
		_ = mutableVowelSet.remove("i")
		XCTAssert(mutableVowelSet.countForElement("i") == 1)
		_ = mutableVowelSet.remove("i")
		XCTAssert(mutableVowelSet.countForElement("i") == 0)
		XCTAssert(mutableVowelSet.contains("i") == false)
		mutableVowelSet.add("i")
		//
		XCTAssert(mutableVowelSet.countForElement("o") == 1)
		mutableVowelSet.add("o")
		XCTAssert(mutableVowelSet.countForElement("o") == 2)
		mutableVowelSet.add("o")
		XCTAssert(mutableVowelSet.countForElement("o") == 3)
		_ = mutableVowelSet.remove("o", always: true)
		XCTAssert(mutableVowelSet.countForElement("o") == 0)
		_ = mutableVowelSet.remove("o")
		XCTAssert(mutableVowelSet.countForElement("o") == 0)
		XCTAssert(mutableVowelSet.contains("o") == false)
		mutableVowelSet.add("o")
		
		mutableVowelSet += "y"
		XCTAssert(mutableVowelSet.count == 6)
		mutableVowelSet += CountedSet(elements: "å","á","â","ä","à","é","ê","è","ë","í","î","ï","ì","ø","ó","ô","ö","ò","ú","û","ü","ù")
		
		XCTAssert(mutableVowelSet.intersectsWithSet(alphabetSet) == true)
		XCTAssert(mutableVowelSet.isSubsetOfSet(alphabetSet) == false)
		var newLetterSet = alphabetSet.setByIntersectionWithSet(mutableVowelSet)
		_ = newLetterSet.remove("y")
		XCTAssert(newLetterSet == vowelSet)
		
		let bracketedLetterSet = vowelSet.map { "[\($0)]" }
		XCTAssert(bracketedLetterSet.contains("[a]") == true)
		
//		var vowelCount = 0
//		var vowelIndex = vowelSet.startIndex
//		do {
//			++vowelCount
//			vowelIndex = vowelIndex.successor()
//		} while vowelIndex != vowelSet.endIndex
//		XCTAssert(vowelCount == 5)
//		XCTAssert(emptySet.startIndex == emptySet.endIndex)
//		
//		println()
//		println("All tests passed.")
//		println()
	}
	
	func testSuppFuncs() {
		
		// capacityMerge
		var s2_1: CountedSet<Character> = []
		var s2_2: CountedSet<Character> = []
		s2_1.add("A", "A", "A", "B", "B",                "C")
		s2_2.add("A",           "B", "B", "B", "B", "B",      "D")
		s2_1.capacityMerge(with: s2_2)
		XCTAssert(s2_1.countForElement("A") == 3)
		XCTAssert(s2_1.countForElement("B") == 5)
		XCTAssert(s2_1.countForElement("C") == 1)
		XCTAssert(s2_1.countForElement("D") == 1)
		
		// expanded
		var s1_1: CountedSet<Character> = []
		s1_1.add("A", "A", "A", "B", "B", "C")
		let a1_1 = s1_1.expanded()
		XCTAssert(a1_1.count == 6)
		XCTAssert(a1_1.filter{ $0 == "A" }.count == 3)
		XCTAssert(a1_1.filter{ $0 == "B" }.count == 2)
		XCTAssert(a1_1.filter{ $0 == "C" }.count == 1)
	}
	
	func testTiming() {
		func timeBlock(_ block: () -> Int) -> (Int, TimeInterval) {
			let start = Date()
			let result = block()
			return (result, Date().timeIntervalSince(start))
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
		print("CountedSet added \(setCreatedCount) unique elements in \(setCreatedTime).")
		
		let (setMatchedCount, setMatchedTime) = timeBlock {
			var matchCount = 0
			for _ in 1...timedSize {
				let num = Int(arc4random_uniform(UInt32(timedSize)))
				if timedSet.contains(num) {
					matchCount += 1
				}
			}
			return matchCount
		}
		print("CountedSet matched \(setMatchedCount) times out of \(timedSize) in \(setMatchedTime).")
		
		let (arrayCreatedCount, arrayCreatedTime) = timeBlock {
			for _ in 1...timedSize {
				let num = Int(arc4random_uniform(UInt32(timedSize)))
				timedArray.append(num)
			}
			return timedArray.count
		}
		print("Array added \(arrayCreatedCount) elements in \(arrayCreatedTime).")
		
		let (arrayMatchedCount, arrayMatchedTime) = timeBlock {
			var matchCount = 0
			for _ in 1...timedSize {
				let num = Int(arc4random_uniform(UInt32(timedSize)))
				if timedArray.contains(num) {
					matchCount += 1
				}
			}
			return matchCount
		}
		print("Array matched \(arrayMatchedCount) times out of \(timedSize) in \(arrayMatchedTime).")
		
		print("")
		print("Array \(Int(setCreatedTime / arrayCreatedTime))x faster at creation than CountedSet.")
		print("CountedSet \(Int(arrayMatchedTime / setMatchedTime))x faster at lookup than Array.")
		
		
		/*
		## WPK
		
		### CountedSet:
		CountedSet added 637 unique elements in 0.0188900232315063.
		CountedSet matched 634 times out of 1000 in 0.00601595640182495.
		Array added 1000 elements in 0.00498300790786743.
		Array matched 626 times out of 1000 in 1.68466699123383.
		
		Array 3x faster at creation than CountedSet.
		CountedSet 280x faster at lookup than Array.
		
		### Set:
		Set added 634 unique elements in 0.0112369656562805.
		Set matched 642 times out of 1000 in 0.00523895025253296.
		Array added 1000 elements in 0.00477802753448486.
		Array matched 623 times out of 1000 in 1.66197401285172.
		
		Array 2x faster at creation than Set.
		Set 317x faster at lookup than Array.
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
		_ = bigSet.remove(setSize)
		let (offsetComparison, offsetComparisonTime) = timeBlock(setEquality)
		bigSet.add(setSize + 1)
		let (unequalComparison, unequalComparisonTime) = timeBlock(setEquality)
		
		print("")
		print("Checked equality (\(equalComparison == 1)) on equal big sets in \(equalComparisonTime)")
		print("Checked equality (\(offsetComparison == 1)) on different-size big sets in \(offsetComparisonTime)")
		print("Checked equality (\(unequalComparison == 1)) on same-size unequal big sets in \(unequalComparisonTime)")
		
		/*
		## WPK
		
		### CountedSet:
		Checked equality (true) on equal big sets in 0.886638045310974
		Checked equality (false) on different-size big sets in 1.96695327758789e-06
		Checked equality (false) on same-size unequal big sets in 0.606709003448486
		
		### Set:
		Checked equality (true) on equal big sets in 0.907741010189056
		Checked equality (false) on different-size big sets in 1.96695327758789e-06
		Checked equality (false) on same-size unequal big sets in 0.633270025253296
		*/
		
		/*
		Checked equality (true) on equal big sets in 0.923960983753204
		Checked equality (false) on different-size big sets in 2.98023223876953e-06
		Checked equality (false) on same-size unequal big sets in 0.908538997173309
		*/
	}
	
	func testAnyElement() {
		var emptySet : CountedSet<String> = CountedSet<String>()
		XCTAssert(emptySet.anyElement() == nil)
		emptySet += "a"
		XCTAssert(emptySet.anyElement() == "a")
	}
}


// MARK: - Timing
