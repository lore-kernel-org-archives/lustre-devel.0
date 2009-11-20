From: Roger Spellman <Roger.Spellman@terascala.com>
Date: Fri, 20 Nov 2009 14:36:29 -0500
Subject: [Lustre-devel] /proc   file bugs
Message-ID: <2C7DE72B9BD00F44BAECA5B0CBB87395844020@hermes.terascala.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It appears to me that there are bugs with handling /proc files for
clients that have rebooted.  

 

For example, if a client reboots, then a file like the following still
exists on the MGS:

 

    /proc/fs/lustre/mgs/MGS/exports/10.2.46.204 at o2ib/stats

 

But, the mgs_disconnect() in mgs_handler.c calls the function
lprocfs_exp_cleanup() in lprocfs_status.c, which calls
lprocfs_free_stats(), which frees the stats structure.

 

So, if you cat that file, you can crash your system.  This is because
the function lprocfs_stats_seq_start() in lprocfs_status.c is getting a
pointer to a data structure that has been freed:

 

static void *lprocfs_stats_seq_start(struct seq_file *p, loff_t *pos)

{

        struct lprocfs_stats *stats = p->private;

        . . .

}

 

That is, 'p' is valid, but p->private has been freed.

 

If I remount the same client, the proc file is not created again (good
thing), and the stats struct is not reallocated (THIS IS BAD, since it
was freed!).  The proc entry's private data is still pointing to a
struct that was freed.  See, for example, mgs_export_stats_init(), which
checks if the NID does not exist before creating a proc file.

 

static int mgs_export_stats_init(struct obd_device *obd,

                                 struct obd_export *exp,

                                 void *localdata)

{

        . . .

        rc = lprocfs_exp_setup(exp, client_nid, &newnid);

        . . .

        if (newnid) {

                exp->exp_ops_stats = lprocfs_alloc_stats(num_stats,

 
LPROCFS_STATS_FLAG_NOPERCPU);

                lprocfs_init_ops_stats(LPROC_MGS_LAST,
exp->exp_ops_stats);

                mgs_stats_counter_init(exp->exp_ops_stats);

                lprocfs_register_stats(exp->exp_nid_stats->nid_proc,
"stats",

                                       exp->exp_ops_stats);

                . . .

        }

}

 

I can think of a few possible solutions:

1.  In lprocfs_exp_cleanup(), don't call lprocfs_free_stats().

2.  When a client disconnect, do proper cleanup of the proc files
(remove them).

 

Regarding solution 2, I looked at the code that creates that particular
proc entry, lprocfs_register_stats(), and it DOES NOT SAVE the
proc_entry, i.e.:

 

int lprocfs_register_stats(struct proc_dir_entry *root, const char
*name,

                           struct lprocfs_stats *stats)

{

        struct proc_dir_entry *entry;

        LASSERT(root != NULL);

 

        entry = create_proc_entry(name, 0644, root);

        if (entry == NULL)

                return -ENOMEM;

        entry->proc_fops = &lprocfs_stats_seq_fops;

        entry->data = (void *)stats;

        return 0;

}

 

So, there is no trivial way to remove the proc entry.  

 

One possible approach would be to add a field to struct lprocfs_stats to
hold the proc entry.  Then, when the stats are freed in
lprocfs_free_stats(),the proc entry can be freed.

 

What do people think of my proposed solutions?  Or, is there something
I'm missing?

 

By the way, this bug exists in both 1.6.x and 1.8.x.

 

Roger Spellman

Staff Engineer

Terascala, Inc.

508-588-1501

www.terascala.com <http://www.terascala.com/>

 

 

 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091120/4c9ca429/attachment.htm>
