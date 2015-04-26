---
title: 'Yars: Multi-Threaded Application Server for Ruby'
authors: 'Ian Ker-Seymer'
date: 'April 27th, 2015'
---

# Overview

Yars is a multithreaded cache/web-server in Ruby. It is compliant with the Ruby
rack framework so it can act as a server for robust frameworks such as Ruby on
Rails and Sinatra. As such, it is very important to ensure performance,
concurrency, and integrity of data. Fortunately, the client-server model of
computing is an inherently parallel form of computation. Generally, the amount
of state shared between different clients and requests is small and can be
easily isolated.

# High-Level Implementation

The basic (high-level) mechanism for the server is this:

1. It takes HTTP requests

2. Checks to see if the request has been made before.

3. Responds with the cached resource if it has been sent before 4. If the
request is new, then it will forward the request to the application 5. The
application decides what to do with the request, and dynamically creates a
response 6. The response is sent from the application to the client 7. Our
server will then close the HTTP transaction with an HTTP response.

# Parallelization challenges

The parallelization challenges involve thread-safe use of the request-response
cache, and the queue used to store pending requests. Both of these data
structures represent hotspots or critical sections in the application, and will
potentially serve thousands of clients at once. Therefore it is crucial to
minimize any sequential bottlenecks found in the implementation, while making
sure that all clients are served in a first-in-first-out ordering.

## Yars::RequestQueue

The concurrency pattern for the Yars queue is known as the Producer-Consumer
model.  In our application, we have two concepts which equate to Producers and
Consumers. They are called Frontend workers and Backend Workers, respectively.

The Frontend workers open a TCPSocket listening on a port of choice, upon
receiving a request, a thread is started which pushes data to to the queue and
subsequently notifies the Backend workers of the fact that there are now
clients to serve. The Backend Workers safely pop data from the queue and begin
reading the request buffer.

The queue built for Yars is a unique design which is somewhat of a combination
of the concepts from a Bounded Partial Queue and an Unbounded Total Queue. Here
are some of the requirements for the queue and how they affected the design
choices for Yars:

1. Firstly, it is neccesary that this queue be unbounded since it is unknown
how many clients may need to be serviced at any given time.

2. We want to minimize the amount of locking required to push and pop from the
queue.

3. We, however, want to benefit of of being able to sleep threads which have no
work to do. This way we wont waste valuable thread resources spinning and
waiting for work when they could be used for other services (database, etc.).
Therefore, we want to be able to use condition variables to signal that there
is work to be done.

As a result our queue is lock-free in the case that there is work on the queue;
however, when there is no work on the queue, we have the threads acquire a lock
solely for the purpose of waiting on a condition variable. This gives us the
benefits of being lock free for the majority of the time while keeping the
useful signalling properties of locks and condition variables.

## Yars::ConcurrentCache

If the request has been made before, we assume the response will always be the
same (this is an immutable server, if you will). It is important to note that
in many cases this property will not be desired; but in certain cases it is
wise to cache certain requests for static material. This option is configurable
by setting a Header in the HTTP response  object known as an E-Tag. When Yars
sees this E-Tag, it can safely cache the request response.

The concurrency pattern for the cache is known as the Readers-Writers model.
All Backend Workers access the shared cache at the same time, some reading and
some writing, with the constraint that no thread may access the cache for
reading or writing while another process is in the act of writing to it.

To implement the cache, we used the concept of a Refined Striped Hash Set. The
way this hash works is by creating a creating two lists: `@table` is a table of
lists which key-value objects are stored, `@locks` is an array of re-entrant
locks used to lock access to each bucket. When Yars caches a response, all it
does is attempt to write the response:request key-value pair to the concurrent
hash table; and upon reading a request it attempts to lookup they request key
in the hash set.

In this hash set, we use an atomic markable reference which indicates an owner
thread and a boolean representing whether or not a resize is in progress. If
there is not resize in progress, we can acquire the lock, hash the value to
determine which bucket our value is in, then linearly search the list for the
value. Afterwards we release the locks.

The interesting about this structure is that it is able to adjust the number of
locks as the number of entries grow. Therefore, as the structure gets larger we
are actually reduce the amount of locking that is needed as the probability of
any given item being in any single bucket reduces.

# Results

# Discussion

# Conclusion
