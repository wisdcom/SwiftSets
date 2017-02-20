// CountedSet.swift
// Copyright (c) 2014 Nate Cook, licensed under the MIT License

import Foundation

public struct CountedSet<T: Hashable> : Equatable {
	public typealias Element = T
	
	fileprivate var contents: Dictionary<Element, Int>
	
	// Create an empty Set.
	public init() {
		self.contents = [:]
	}
	
	// Create a Set from the given sequence.
	public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element {
		self.contents = [:]
		for each in sequence { self.add(each) } // sequence.map { self.add($0) }
	}
	
	public init(elements: Element...) {
		self.init()
		for each in elements { self.add(each) } // elements.map { self.add($0) }
	}
	
	// Create an empty Set while reserving capacity for at least `minimumCapacity` elements.
	public init(minimumCapacity: Int) {
		self.contents = Dictionary(minimumCapacity: minimumCapacity)    
	}
	
	/// The number of elements in the Set.
	public var count: Int { return contents.count }
	
	/// Returns `true` if the Set is empty.
	public var isEmpty: Bool { return contents.isEmpty }
	
	/// The elements of the Set as an array.
	public var elements: [Element] { return Array(self.contents.keys) }
	
	/// Returns `true` if the Set contains `element`.
	public func contains(_ element: Element) -> Bool {
		return contents[element] != nil
	}
	
	/// Returns the count for an element, 0 if not present.
	public func countForElement(_ element: Element) -> Int {
		return contents[element] ?? 0
	}
	
	/// `true` if the Set contains `element`, `false` otherwise.
	public subscript(element: Element) -> Bool {
		return contains(element)
	}
	
	/// Add a single `newElement` to the Set.
	public mutating func add(_ newElement: Element) {
		if self.contains(newElement) {
			contents[newElement]! += 1
		} else {
			contents[newElement] = 1
		}
	}
	
	/// Add multiple `newElements` to the Set.
	public mutating func add(_ newElement: Element, _ anotherNewElement: Element, _ otherNewElements: Element...) {
		add(newElement)
		add(anotherNewElement)
		for each in otherNewElements { self.add(each) } // otherNewElements.map { self.add($0) }
	}
	
	/// Remove `element` from the Set.
	public mutating func remove(_ element: Element, always: Bool = false) -> Element? {
		if always {
			return self.contents.removeValue(forKey: element) != nil ? element : nil
		}
		
		if self.contains(element) {
			contents[element]! -= 1
			
			if contents[element]! == 0 {
				contents.removeValue(forKey: element)
			}
			return element
			
		} else {
			return nil
		}
	}
	
	/// Removes all elements from the Set.
	public mutating func removeAll() {
		contents = [Element: Int]()
	}
	
	/// Returns a new Set including only those elements `x` where `includeElement(x)` is true.
	public func filter(_ includeElement: (T) -> Bool) -> CountedSet<T> {
		return CountedSet(self.contents.keys.filter(includeElement))
	}
	
	/// Returns a new Set where each element `x` is transformed by `transform(x)`.
	public func map<U>(_ transform: (T) -> U) -> CountedSet<U> {
		return CountedSet<U>(self.contents.keys.map(transform))
	}
	
	/// Returns a single value by iteratively combining each element of the Set.
	public func reduce<U>(_ initial: U, combine: (U, T) -> U) -> U {
		return self.reduce(initial, combine: combine)
	}
	
	/// Returns an element from the set, likely the first.
	public func anyElement() -> Element? { return elements.first }
	
	
	//
	
	
	/// Merges with a second set, limiting the counts to the greater of the two.
	/// e.g.
	///
	///			let set1 = [ a(3), b(2), c(1) ]
	///			let set2 = [ a(1), b(5), d(1) ]
	///			set1.capacityMerge(with: set2)
	///			// set1 is now [ a(3), b(5), c(1), d(1) ]
	///
	/// - Parameter secondSet: the set to merge with
	///
	public mutating func capacityMerge(with secondSet: CountedSet<T>) {
		
		for eachElement in secondSet {
			let countInFirstSet  = self.countForElement(eachElement)
			let countInSecondSet = secondSet.countForElement(eachElement)
			
			let underInFirstSet = countInSecondSet - countInFirstSet
			if underInFirstSet >= 1 {
				for _ in 1...underInFirstSet {
					self.add(eachElement)
				}
			}
		}
	}
	
	/// Returns a new array with elements repeating according to the counts.
	/// e.g. [ a(3), b(2), c(1) ] -> [ a, a, a, b, b, c ]
	///
	public func expanded() -> Array<Element> {
		var expanded: Array<Element> = []
		
		for eachElement in self {
			let elementCount = countForElement(eachElement)
			for _ in 1...elementCount {
				expanded.append(eachElement)
			}
		}
		return expanded
	}
}

// MARK: SequenceType

extension CountedSet : Sequence {
	
	public typealias Iterator = AnyIterator<T>
	
	/// Creates a generator for the items of the set.
	public func makeIterator() -> Iterator {
		var generator = contents.keys.makeIterator()
		return AnyIterator {
			return generator.next()
		}
	}
}

// MARK: ArrayLiteralConvertible

extension CountedSet : ExpressibleByArrayLiteral {
	
	public init(arrayLiteral elements: Element...) {
		self.init(elements)
	}
}

// MARK: Set Operations

extension CountedSet {
	
	/// Returns `true` if the Set has the exact same members as `set`.
	public func isEqualToSet(_ set: CountedSet<T>) -> Bool {
		return self.contents == set.contents
	}
	
	/// Returns `true` if the Set shares any members with `set`.
	public func intersectsWithSet(_ set: CountedSet<T>) -> Bool {
		for elem in self {
			if set.contains(elem) {
				return true
			}
		}
		return false
	}
	
	/// Returns `true` if all members of the Set are part of `set`.
	public func isSubsetOfSet(_ set: CountedSet<T>) -> Bool {
		for elem in self {
			if !set.contains(elem) {
				return false
			}
		}
		return true
	}
	
	/// Returns `true` if all members of `set` are part of the Set.
	public func isSupersetOfSet(_ set: CountedSet<T>) -> Bool {
		return set.isSubsetOfSet(self)
	}
	
	/// Modifies the Set to add all members of `set`.
	public mutating func unionSet(_ set: CountedSet<T>) {
		for elem in set {
			self.add(elem)
		}
	}
	
	/// Modifies the Set to remove any members also in `set`.
	public mutating func subtractSet(_ set: CountedSet<T>, alwaysRemove: Bool = false) {
		for elem in set {
			_ = self.remove(elem, always: alwaysRemove)
		}
	}
	
	/// Modifies the Set to include only members that are also in `set`.
	public mutating func intersectSet(_ set: CountedSet<T>) {
		self = self.filter { set.contains($0) }
	}
	
	/// Returns a new Set that contains all the elements of both this set and the set passed in.
	public func setByUnionWithSet(_ set: CountedSet<T>) -> CountedSet<T> {
		var resultSet = set
		resultSet.extend(self)
		return resultSet
	}
	
	/// Returns a new Set that contains only the elements in both this set and the set passed in.
	public func setByIntersectionWithSet(_ set: CountedSet<T>) -> CountedSet<T> {
		var resultSet = set
		resultSet.intersectSet(self)
		return resultSet
	}
	
	/// Returns a new Set that contains only the elements in this set *not* also in the set passed in.
	public func setBySubtractingSet(_ set: CountedSet<T>, alwaysRemove: Bool = false) -> CountedSet<T> {
		var newSet = self
		newSet.subtractSet(set, alwaysRemove: alwaysRemove)
		return newSet
	}
}

// MARK: ExtensibleCollectionType

extension CountedSet { // : ExtensibleCollectionType {
	
	public typealias Index = CountedSetIndex<T>
//	public var startIndex: Index {
//		return CountedSetIndex(contents.startIndex)
//	}
//	public var endIndex: Index {
//		return CountedSetIndex(contents.endIndex)
//	}
	
	/// Returns the element of the Set at the specified index.
//	public subscript(i: Index) -> Element {
//		return contents.keys[i.index]
//	}
	
	public mutating func reserveCapacity(_ n: Int) {
		// can't really do anything with this
	}
	
	/// Adds newElement to the Set.
	public mutating func append(_ newElement: Element) {
		self.add(newElement)
	}
	
	/// Extends the Set by adding all the elements of `seq`.
	public mutating func extend<S : Sequence>(_ seq: S) where S.Iterator.Element == Element {
		for each in seq { self.add(each) } // seq.map { self.add($0) }
	}
}

// MARK: Printable

extension CountedSet : CustomStringConvertible, CustomDebugStringConvertible {
	
	public var description: String {
		return "CountedSet(\(self.elements))"
	}
	
	public var debugDescription: String {
		return description
	}
}

// MARK: Operators

public func +=<T>(lhs: inout CountedSet<T>, rhs: T) {
	lhs.add(rhs)
}

public func +=<T>(lhs: inout CountedSet<T>, rhs: CountedSet<T>) {
	lhs.unionSet(rhs)
}

public func +<T>(lhs: CountedSet<T>, rhs: CountedSet<T>) -> CountedSet<T> {
	return lhs.setByUnionWithSet(rhs)
}

public func ==<T>(lhs: CountedSet<T>, rhs: CountedSet<T>) -> Bool {
	return lhs.isEqualToSet(rhs)
}


// MARK: - CountedSetIndex


public struct CountedSetIndex<T: Hashable> { // : BidirectionalIndexType {
	
	private var index: DictionaryIndex<T, Int>
	private init(_ dictionaryIndex: DictionaryIndex<T, Int>) {
		self.index = dictionaryIndex
	}
	//	public func predecessor() -> CountedSetIndex<T> {
	//		return CountedSetIndex(self.index.predecessor())
	//	}
//	public func successor() -> CountedSetIndex<T> {
//		return CountedSetIndex(<#T##Dictionary corresponding to your index##Dictionary#>.index(after: self.index))
//	}
}

//public func ==<T: Hashable>(lhs: CountedSetIndex<T>, rhs: CountedSetIndex<T>) -> Bool {
//	return lhs.index == rhs.index
//}
