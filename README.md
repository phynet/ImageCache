# Image Cache

I don't know if I will remember how to write this in the future... so I put it on a repo for future me, or you.

How to cache image inside a UIImageView extension (spoiler: you need AssociatedKeys and NSCache)

You will use it like:

```swift 
thumbnailImageView.setImage(with: url)
```

One thing to note here, is that there's a **countLimit** that indicates the amount of objects the cache should hold. Zero means no limit, so the cache will store objects indefinitely, I didn't set any, so this cache will store images until the system requires free memory.


We can also set a maximum cost of the cache. For example: 50,000,000 bytes

```swift 
cache.totalCostLimit = 50_000_000
```

## Associated Keys

**What are they?**

When you use extension, we found a limitation, we cannot add a property to an existing class from an extension. That's why we endup using Associated keys, or more especific **Objective-c associated objects**. We just add a computed property with objc_get/setAssociatedObject() in the backing get and set blocks. 

**But why?**
You want to give a new functionality to ImageView, and the best way of doing that is using extensions. Sadly as mentioned before, we cannot add properties to an existing class from an extension, so the best way of handling it is by using associated objects.

You can read more about it: 
https://nshipster.com/swift-objc-runtime/


Thanks to @juanpe for the starting point
