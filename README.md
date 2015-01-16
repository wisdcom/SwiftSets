# SwiftSets

SwiftSets is an exploration: implementing new data structures in Swift with the same features that first-party structures like Array and Dictionary enjoy. `Set` is the first implementation.

## Included Types

`Set`: an unordered collection of unique values with O(1) lookup for set membership. For more information about the creation of this type, see [this post](http://natecook.com/blog/2014/08/creating-a-set-type-in-swift).

`CountedSet`: based on `Set`, and with inspirations from `NSCountedSet`, each element in a `CountedSet` has an associated counter, keeping track of how many times the element has been added into the set.

## License

SwiftSets is (c) 2014 Nate Cook and available under the MIT license.
