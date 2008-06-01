From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Sun, 01 Jun 2008 17:58:36 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <20080601045302.GA29979@eng.sun.com>
References: <18493.29199.765234.755534@gargle.gargle.HOWL>
	<C46829E1.5610%peter.braam@sun.com>
	<20080601045302.GA29979@eng.sun.com>
Message-ID: <18498.43788.847173.750390@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Jeff Bonwick writes:
 > I'd suggest working with Matt Ahrens on this.

Hello,

we were discussing recently what is needed from the DMU to implement quotas
and other forms of space accounting. Our basic premise is that it is desirable
to keep DMU part of the quota support at minimum, and to implement only
mechanism here, leaving policy to the upper layers.

Questions of what exactly constitutes disk space usage for quota purposes
(e.g., whether and how snapshots have to be accounted for, etc.) are
orthogonal to the present interface discussion; it's assumed that
dnode_phys_t::dn_used can be used for this.

Two main use cases are

    - user and group quotas in ZPL, and

    - distributed cluster-wide quota in Lustre and pNFS.

Surprisingly, it seems that these use cases can be implemented without any
additional support from the DMU, except for the commit call-back, that is
needed for other purposes too.

General idea is that DMU user (ZPL or Lustre MDD module) maintains its own
data-base mapping quota consumers (user and group identifiers) to their
current space usage. A mechanism is needed to keep this data-base up to date.

To this end, user keeps in memory a list of all DMU objects to which space was
allocated or deallocated ("pending list"). User can do this, provided it has
full control of the DMU (which holds for both use cases above). See below on
how pending list is truncated. For each object, pending list also records its
"current space usage" (dnode_phys_t::dn_used), and there is at most one record
for a given object in this list.

When a transaction group is about to be closed, user finds all objects in the
pending list, belonging to this or previous transaction groups and, in the
context of this transaction group, appends to a special "pending file" a
record, containing

        (object id, current space usage)

Next, transaction group is synced, disk space is actually allocated to the
objects, and dnode_phys_t::dn_used is modified.

When transaction group has committed, commit call-back is invoked. In this
call-back user scans pending list, and updates its internal quota data-base:

        foreach (object, space_usage) in list {
                upd_quota(object->owner, dnode->dn_used - space_usage);
                upd_quota(object->group, dnode->dn_used - space_usage);
                remove_record_from_list();
        }

Updates to the user's quota data-base are done in the context of
currently open transaction.

When DMU starts (possibly after a crash), the same loop as above is
executed for all records in the pending file (as visible in last
committed transaction group). Note that this loop is idempotent:
executing it second time after first execution successfully committed
has no result.

In other words, the idea is to update quota data-base on the transaction
group commit (so that updates to the data-base go into the transaction
group in the "future" w.r.t. object operations that resulted in the
space allocation), and to keep in pending file a list of objects
modified during the last 2 transaction groups, so that this file can be
used as a kind of redo log to update quota data-base in case of failure.

 > 
 > Jeff

Nikita.
