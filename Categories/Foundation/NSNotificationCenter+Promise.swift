import Foundation.NSNotification
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `NSNotificationCenter` category:

    use_frameworks!
    pod "PromiseKit/Foundation"

 Or `NSNotificationCenter` is one of the categories imported by the umbrella pod:

    use_frameworks!
    pod "PromiseKit"

 And then in your sources:

    import PromiseKit
*/
extension NSNotificationCenter {
    public class func once(name: String) -> NotificationPromise<[NSObject: AnyObject]> {
        return NSNotificationCenter.defaultCenter().once(name)
    }
    
    public func once(name: String) -> NotificationPromise<[NSObject: AnyObject]> {
        let (promise, fulfill) = NotificationPromise<[NSObject: AnyObject]>.go()
        let id = addObserverForName(name, object: nil, queue: nil, usingBlock: fulfill)
        promise.then(on: zalgo) { _ in self.removeObserver(id) }
        return promise
    }
}

public class NotificationPromise<T>: Promise<T> {
    private let (parentPromise, parentFulfill, _) = Promise<NSNotification>.pendingPromise()
    
    public func asNotification() -> Promise<NSNotification> {
        return parentPromise
    }
    
    private class func go() -> (NotificationPromise<[NSObject: AnyObject]>, (NSNotification) -> Void) {
        var fulfill: (([NSObject: AnyObject]) -> Void)!
        let promise = NotificationPromise<[NSObject: AnyObject]> { f, _ in fulfill = f }
        promise.parentPromise.then { fulfill($0.userInfo ?? [:]) }
        return (promise, promise.parentFulfill)
    }
    
    private override init(@noescape resolvers: (fulfill: (T) -> Void, reject: (ErrorType) -> Void) throws -> Void) {
        super.init(resolvers: resolvers)
    }
}
