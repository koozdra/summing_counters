# Summing Counters
A Phoenix application that listens on port `3333` and accepts json post requests on the `/increment` route. Writes to the database are buffered under a key name and flushed on a timer per key.

## Getting up and running
`docker pull postgres`
`docker run --name postgresql-container -p 5432:5432 -e POSTGRES_PASSWORD=postgres -d postgres`
`mix ecto.setup`
`mix deps.get`
`mix phx.server`

## Integration Test
`mix run test/integration/single_key.exs --no-start`

## Postgres Atomic Increment Upsert and Row Locking
A postgres atomic increment upsert is used to update the database. With this type of update postgres will lock the row for updates which creates
contention if many updates are happening on the same row. To mitigate this, writes to postgres are buffered using [DataBuffer](https://hexdocs.pm/data_buffer/0.1.0/DataBuffer.html) under a key name. When we have multiple servers running this app, writes under the same key will still line up for updates but that should be done at a reasonable rate (this would have to be tuned to the running application).

## Drawbacks to this approach
### Service Crashes and Restarts for Deployment
DataBuffer uses ETS, an in memory nosql database. If the service crashes or is restarted before the flush period, in memory accumulated counters will be lost. One way to mitigate planned restarts is to listen for the service shutting down and flush all buffers before shutting down.

### ETS Memory Usage Concern
If there is a very high volume of writes, DataBuffer's usage of ETS is unbounded and can consume all of the servers memory. To mitigate this we can tune the flush period so the accumulation of counters doesn't consume too much memory.

### Efficiency
DataBuffer maintains a list of updates. This means the list of updates are aggregate on buffer flush. In our use case we are summing under a key so it would be more efficient to sum the values using ETS in memory when writing to the cache. This way only one value per key is maintained in memory and makes writes at flush intervals more performant.

## TODO
### Database Interaction Error Handling
DataBuffer has a `handle_error` callback that was not implemented. During any database down time when data cannot be written, writes will fail and that has to be handled in the application.

### Unit Tests
I ran out of time to write the unit tests. Elixir does not make it easy to work with mocks and requires work to create abstractions over external dependencies in order to test them. Given more time I would definitely test the controller and the database interaction code. To compensate I wrote an integration test that can be run to confirm that writing to the same key works and is performant.

## Alternative Approaches
### Postgres Aggregation Table
If in memory aggregation using ETS to buffer writes to postgres is too volatile, we instead can maintain a log table in the database. Then have some asynchronous process aggregate the log table and write to the main counters table.

### Queue Service (eg. SQS)
Another approach would be to use a queueing service such as SQS to maintain a queue of writes to postgres. When a request comes in to the service a
message is enqueued in SQS. We can have an independently deployed queue processing system that will process messages as it writes messages. This system can scale with the size of the queue to ensure data is kept up to date. [Broadway](https://github.com/dashbitco/broadway) can also batch writes to postgres when processing many messages for the same key name. 
