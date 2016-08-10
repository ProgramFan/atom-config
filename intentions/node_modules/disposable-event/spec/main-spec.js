'use babel'

import {EventEmitter} from 'events'
import {CompositeDisposable} from 'sb-event-kit'
import disposableEvent from '..'

describe('disposableEvent', function() {
  it('works well with addEventListener/removeEventListener', function() {
    let called = 0
    const element = document.createElement('div')
    const subscriptions = new CompositeDisposable()

    subscriptions.add(disposableEvent(element, 'mousemove', function() {
      called++
    }))
    expect(called).toBe(0)
    element.dispatchEvent(new MouseEvent('mousemove'))
    expect(called).toBe(1)
    element.dispatchEvent(new MouseEvent('mousemove'))
    expect(called).toBe(2)
    subscriptions.dispose()
    element.dispatchEvent(new MouseEvent('mousemove'))
    expect(called).toBe(2)
  })
  it('works well with node\'s event emitter', function() {
    let called = 0
    const emitter = new EventEmitter()
    const subscriptions = new CompositeDisposable()

    subscriptions.add(disposableEvent(emitter, 'something', function() {
      called++
    }))
    expect(called).toBe(0)
    emitter.emit('something')
    expect(called).toBe(1)
    emitter.emit('something')
    expect(called).toBe(2)
    subscriptions.dispose()
    emitter.emit('something')
    expect(called).toBe(2)
  })
})
