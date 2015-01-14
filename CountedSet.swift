// CountedSet.swift
// Copyright (c) 2014 Nate Cook, licensed under the MIT License

import Foundation

public struct CountedSet<T: Hashable> : Equatable {
	
	typealias Element = T
	private var contents: Dictionary<Element, Int>
	
	// Create an empty Set.
	public init() {
		self.contents = [:]
	}
	
	// Create a Set from the given sequence.
	public init<S: SequenceType where S.Generator.Element == Element>(_ sequence: S) {
		self.contents = [:]
		Swift.map(sequence) { self.add($0) }
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
	public func contains(element: Element) -> Bool {
		return contents[element] > 0 // TODO: !
	}
	
	/// `true` if the Set contains `element`, `false` otherwise.
	public subscript(element: Element) -> Bool {
		return contains(element)
	}
	
	/// Add a single `newElement` to the Set.
	public mutating func add(newElement: Element) {
		self.contents[newElement] = 1 // TODO: !
	}
	
	/// Add multiple `newElements` to the Set.
	public mutating func add(newElement: Element, _ anotherNewElement: Element, _ otherNewElements: Element...) {
		add(newElement)
		add(anotherNewElement)
		otherNewElements.map { self.add($0) }
	}
	
	/// Remove `element` from the Set.
	public mutating func remove(element: Element) -> Element? {
		return contents.removeValueForKey(element) != nil ? element : nil
	}
	
	/// Removes all elements from the Set.
	public mutating func removeAll() {
		contents = [Element: Int]()
	}
	
	/// Returns a new Set including only those elements `x` where `includeElement(x)` is true.
	public func filter(includeElement: (T) -> Bool) -> CountedSet<T> {
		return CountedSet(self.contents.keys.filter(includeElement))
	}
	
	/// Returns a new Set where each element `x` is transformed by `transform(x)`.
	public func map<U>(transform: (T) -> U) -> CountedSet<U> {
		return CountedSet<U>(self.contents.keys.map(transform))
	}
	
	/// Returns a single value by iteratively combining each element of the Set.
	public func reduce<U>(var initial: U, combine: (U, T) -> U) -> U {
		return Swift.reduce(self, initial, combine)
	}
}

// MARK: SequenceType

extension CountedSet : SequenceType {
	
	typealias Generator = GeneratorOf<T>
	
	/// Creates a generator for the items of the set.
	public func generate() -> Generator {
		var generator = contents.keys.generate()
		return Swift.GeneratorOf {
			return generator.next()
		}
	}
}

// MARK: ArrayLiteralConvertible

extension CountedSet : ArrayLiteralConvertible {
	
	public init(arrayLiteral elements: Element...) {
		self.init(elements)
	}
}

// MARK: Set Operations

extension CountedSet {
	
	/// Returns `true` if the Set has the exact same members as `set`.
	public func isEqualToSet(set: CountedSet<T>) -> Bool {
		return self.contents == set.contents
	}
	
	/// Returns `true` if the Set shares any members with `set`.
	public func intersectsWithSet(set: CountedSet<T>) -> Bool {
		for elem in self {
			if set.contains(elem) {
				return true
			}
		}
		return false
	}
	
	/// Returns `true` if all members of the Set are part of `set`.
	public func isSubsetOfSet(set: CountedSet<T>) -> Bool {
		for elem in self {
			if !set.contains(elem) {
				return false
			}
		}
		return true
	}
	
	/// Returns `true` if all members of `set` are part of the Set.
	public func isSupersetOfSet(set: CountedSet<T>) -> Bool {
		return set.isSubsetOfSet(self)
	}
	
	/// Modifies the Set to add all members of `set`.
	public mutating func unionSet(set: CountedSet<T>) {
		for elem in set {
			self.add(elem)
		}
	}
	
	/// Modifies the Set to remove any members also in `set`.
	public mutating func subtractSet(set: CountedSet<T>) {
		for elem in set {
			self.remove(elem)
		}
	}
	
	/// Modifies the Set to include only members that are also in `set`.
	public mutating func intersectSet(set: CountedSet<T>) {
		self = self.filter { set.contains($0) }
	}
	
	/// Returns a new Set that contains all the elements of both this set and the set passed in.
	public func setByUnionWithSet(var set: CountedSet<T>) -> CountedSet<T> {
		set.extend(self)
		return set
	}
	
	/// Returns a new Set that contains only the elements in both this set and the set passed in.
	public func setByIntersectionWithSet(var set: CountedSet<T>) -> CountedSet<T> {
		set.intersectSet(self)
		return set
	}
	
	/// Returns a new Set that contains only the elements in this set *not* also in the set passed in.
	public func setBySubtractingSet(set: CountedSet<T>) -> CountedSet<T> {
		var newSet = self
		newSet.subtractSet(set)
		return newSet
	}
}

// MARK: ExtensibleCollectionType

extension CountedSet : ExtensibleCollectionType {
	
	typealias Index = CountedSetIndex<T>
	public var startIndex: Index { return CountedSetIndex(contents.startIndex) }
	public var endIndex: Index { return CountedSetIndex(contents.endIndex) }
	
	/// Returns the element of the Set at the specified index.
	public subscript(i: Index) -> Element {
		return contents.keys[i.index]
	}
	
	public mutating func reserveCapacity(n: Int) {
		// can't really do anything with this
	}
	
	/// Adds newElement to the Set.
	public mutating func append(newElement: Element) {
		self.add(newElement)
	}
	
	/// Extends the Set by adding all the elements of `seq`.
	public mutating func extend<S : SequenceType where S.Generator.Element == Element>(seq: S) {
		Swift.map(seq) { self.add($0) }
	}
}

// MARK: Printable

extension CountedSet : Printable, DebugPrintable {
	
	public var description: String {
		return "Set(\(self.elements))"
	}
	
	public var debugDescription: String {
		return description
	}
}

// MARK: Operators

public func +=<T>(inout lhs: CountedSet<T>, rhs: T) {
	lhs.add(rhs)
}

public func +=<T>(inout lhs: CountedSet<T>, rhs: CountedSet<T>) {
	lhs.unionSet(rhs)
}

public func +<T>(lhs: CountedSet<T>, rhs: CountedSet<T>) -> CountedSet<T> {
	return lhs.setByUnionWithSet(rhs)
}

public func ==<T>(lhs: CountedSet<T>, rhs: CountedSet<T>) -> Bool {
	return lhs.isEqualToSet(rhs)
}


// MARK: - CountedSetIndex


public struct CountedSetIndex<T: Hashable> : BidirectionalIndexType {
	
	private var index: DictionaryIndex<T, Int>
	private init(_ dictionaryIndex: DictionaryIndex<T, Int>) {
		self.index = dictionaryIndex
	}
	public func predecessor() -> CountedSetIndex<T> {
		return CountedSetIndex(self.index.predecessor())
	}
	public func successor() -> CountedSetIndex<T> {
		return CountedSetIndex(self.index.successor())
	}
}

public func ==<T: Hashable>(lhs: CountedSetIndex<T>, rhs: CountedSetIndex<T>) -> Bool {
	return lhs.index == rhs.index
}