From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Mon, 15 Feb 2010 19:56:50 +0300
Subject: [Lustre-devel] mtime and ctime handling in lustre
Message-ID: <182A1028-6F63-43D5-9BF8-F16E03F4C41D@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As we have many problems with *time handling, some long standing bugs
(11063) and new ones appear (21489) I have tried to sort this out and
to design a proper solution, the results are below.

I. Client inode may cache new modification attributes which must not
be overwritten by server attributes until modification is sent out to
server.

Modifications: write, setattr, punch. Operations like glimpse, enqueue,
punch brings OST attributes and overwrite osc_lvb and inode attributes
(ll_glimpse_size, ll_lock_enqueue, ll_file_punch).

Solution 1. Leave client inode for new modification attribute only.

Do not overwrite it with server attributes at all; although it could be
merged (leaving the largest time in inode) with server ones as we do in
ll_update_inode(). OST attributes in its turn will be stored in
osc_lvb.

Solution 2. Store new modification attributes and OST ones in osc_lvb
protecting osc_lvb changes with extent lock.

New modification attributes are stored in osc_lvb only under extent
lock, lockless modification do not change it;
OST attributes can only overwrite osc_lvb under [0;eof] lock, what
means all the previous modifications are already flushed on OST,
osc_lvb is not changed with no lock or under a partial one.

Solution 3. Store new modification attributes and OST ones in inode
protecting these changes with extent lock.

The same as Solution 2, but needs all the extent locks to be taken in
operations like glimpse to update inode.

II. Client inode without locks has obsolete attributes and if stat()
will merge inode with MDS and OST attributes, the result will be wrong
for set-in-past case.

Solution 1&2: stat() should return the merge of MDS and OST attributes
only (i.e. lli_lvb & osc_lvb) without inode ones.

Solution 3: stat() will overwrite inode with new attributes, so no
problem here.

III. Stat() done after modification must return new attributes, even if
the modification is not sent to OST immediately.

Solution 1: as stat() does not take inode attributes, osc_lvb needs to
cache new modifications, thus "locked" modification (which takes client
side locks) must update osc_lvb right on modification. As osc_lvb has
to keep modification attributes anyway -- solution 1 has no sence
anymore.

Solution 2 / solution 3: osc_lvb / inode must be updated on "locked"
modification immediately after taking extent lock, even if client is
going to cache the change for a while.

IV. Reply from OST with OST attributes must overwrite osc_lvb / inode
(for solution 2 / 3) IIF the operation has taken a client side [0;eof]
extent lock for itself.

If client already had [0;eof] lock, it already had a full contol over
OST attributes and lockless operation should not change it as it could
be out-of-date.

If client has some not [0;eof] PW lock, due to (III) it may cache the
modification attributes in osc_lvb / inode and lockless or partially
locked operations should not overwrite osc_lvb / inode to not lose
them; the following glimpse will go to OST anyway.

E.g.: there is a dirty cache on client, read->enqueue takes another
lock, it must not overwrite osc_lvb / inode to let stat() return proper
attributes later.

Solution 2 / 3: all the lockless (LL) operations must not apply OST
attributes (obtained in replies) to osc_lvb/inode: getattr, LL setattr,
LL write, LL punch, LL glimpse;

others must check if they have taken [0;eof] lock: enqueue,write,punch;

V. osc_lvb / inode attributes do not need to be updated when we prepare
RPC to OST (they were already updated when the modification happened).

Indeed, if client has a partial lock, glimpse will go to OST but will
not overwrite osc_lvb / inode; if full lock, nobody has changed osc_lvb
since the modification has taken place.

VI. Several parallel modifications under the same lock (bug=21489)

Client may send some modification in 1 order, server may handle them in
another, client may get replied in 3rd. Even having [0;eof] lock
osc_lvb/inode could be modified in wrong order -- not as modifications
are applied to OST.

Solution 2 / 3: we still need to apply attributes replied from OST to
osc_lvb / inode, but in the OST transID order.

E.g.: client sends write and set-in-past happens.

Involved OPS: write, setattr, locked punch.

Note, setattr and lockled punch are protected by mutex, so they cannot
race to each other, whereas write rpc may be sent much later than write
syscall happened.

In general: solution 2 looks easier to implement. I.e. the proper
attributes will be stored in lli_lvb & osc_lvb, client inode attributes
are not used (although could cache new modification attributes, as it
is already used this way, so it is easier to implement)

Use Cases (describe the worst scenarious we may run into not related to
solutions described above):
I.
1. ls -la on 2 clients
    extent locks are obtained on clients;
2. set-in-past
    we set mtime on all the ost and mds but do not cancel extent locks;
3. ls -la on 2 clients
    time must be the same set in past
II.
1. write
    sets new mtime, ctime on OSTs
2. chmod, rename, link, unlink
    sets new ctime on MDS
3. close (may happen before 2)
    may update some *time attributes on MDS with OST ones.
4. ls -la
    must show OST's mtime.
III.1
1. client1 writes
    changes mtime, ctime on osts.
2. client1 (or client2) sets-in-past within the same second (or not).
    changes mtime,ctime on MDS,OST
3. client1 closes (may happen before 2)
    may update some *time attributes on MDS with OST ones.
4. client1 does ls -la
    must show mtime in past.
III.2
1. client1 writes
    changes mtime, ctime on OST
2. client1 setattrs (or locked punch) from the same client
    (not necessary in past, under the same extent lock)
    changes mtime, ctime on OST
3. client1 write reply
    updates osc_lvb with writen mtime
4. client1 setattr reply
    does not update osc_lvb
5. client1 does ls -la
    must show setattr's (punch's) mtime
IV.1
1. client1 caches a write (full or partial lock)
    changes mtime, ctime on OST
2. client1 glimpses
    gets OST attributes, puts them to osc_lvb, updates inode with them
3. ls -la
    must show write's *time
IV.2
1. client1 does setattr-in-past -- enqueue is sent
2. client1 glimpses -- enqueue is sent
    gets OST attributes, puts them to osc_lvb, updates inode with them
3. client1 does setattr-in-past -- setattr is sent
    client has taken locks on OST, mtime&ctime is updated in inode
4. glimpses reply
    no lock, glimpses changes osc_lvb and inode
3. ls -la
    must show setattr's *time
IV.3.
1. client1 caches data under partial lock
    changes mtime&ctime on client in inode & osc_lvb
2. client1 does read under not conflicting lock
    gets OST attrs in enqueue reply in osc_lvb & inode
3. client1 writes to OST with wrong data
    must not lose write attrs
V.
1. client1 does ls -la
    gets MDs & OST attributes
2. client1 cancels locks
3. client2 sets-in-past
4. client1 does ls -la
    must show time in past, not taken from the inode still cached on
    client1.

--
Vitaly
