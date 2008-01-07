From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Mon, 07 Jan 2008 10:25:37 +0100
Subject: [Lustre-devel] server changelogs
In-Reply-To: <4755D76F.9080604@sun.com>
References: <4755D76F.9080604@sun.com>
Message-ID: <4781F011.6020807@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Nathan -

Good page, here are some comments.

Peter

Mention other internal consumers such as replication, rollback and
orphan recovery mechanisms.

1. In the Qualities - describe what a records should be capable of
(redo, undo, pathname reconstruction).  Physiology is not a common term,
"Operation based" logging is common (better than intents).

2. change the subheadings on the use cases please.

3. For audit many things are logged.  Failed authorization attempts are
the most important as are file removals and opens.  Write more detail in
the response part.

4. Database sync - transactional qualities are critical.  Again, the
response is too short.  Also pathname reconstruction shows that records
have to contain unexpected fields, such as parent fids.

5. HSM_Aging - I thought HSM aging would be done with a separate log to
record read-only accesses. This log works in conjunction with an inode
in the EA which points to the log record.

6. Replication.  One needs to do unexpected things, such as setting the
mtime of parent directories to what was used on the client and checking
that versions of objects were the same on client and server.  This leads
to a more detailed description of fields in the changelog records.

7. Undo leads to more interesting field descriptions for the records.
What is the difference between rollback and undo?

8. Requierements are best formulated with the QAW tables.

9. Scope - dependent transactions probably have to be recorded as such.
Physiology - almost all changelogs must be created transactionally in
conjunction with file system updates. Consistency (strange word) - I
think we are shooting for parallel replication algorithms for
scalability as well as combining records for FS wide streams?  How -
this should be a QAW outlining the algorithm.  Discuss retention
behavior in detail for multiple consumers of one record in the presence
of rollback epoch markers.  Log content - filename is naive - what about
fids, parent fids etc?  API - no harm in being more explicit here.

10. Feeds per consumer may lead to too many logs I think.  I was
thinking about multiple cancellation bits or a ref count on records.
Remember that these logs must be in catalogs for scalability.  In some
cases logs may need to be recompacted.





Nathan Rutman wrote:
> Use cases updated.  I think this is solid now.   What are the next steps?
> http://arch.lustre.org/index.php?title=Server_Changelogs
