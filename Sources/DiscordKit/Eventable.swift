/// Create a nifty Event Emitter in Swift
protocol Eventable {

    /// Event Listeners
    var listeners: [SubscribableEvent: [(Any) -> ()]] { get set }

    /**
    - parameter event: Event to listen for
    */
    mutating func on(_ event: SubscribableEvent, do function: @escaping (Any) -> ())

    /**
    - parameter event: Event to emit
    - parameter data: Array of stuff to emit listener with
    */
    func emit(_ event: Event)
  
}

extension Eventable {

    mutating public func on(_ event: SubscribableEvent, do function: @escaping (Any) -> ()) {
        guard self.listeners[event] != nil else {
            self.listeners[event] = [function]
            return
        }

        self.listeners[event]!.append(function)
    }

    public func emit(_ event: Event) {
        guard let listeners = self.listeners[event.subscribable] else { return }

        switch event {
        case .ready(let data):
            call(data)
        case .message(let data):
            call(data)
        case .unknown(let data):
            call(data!)
        }

        func call(_ data: Any) {
            for listener in listeners {
                listener(data)
            }
        }
        
    }
  
}