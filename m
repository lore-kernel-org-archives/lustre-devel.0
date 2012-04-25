From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Wed, 25 Apr 2012 09:36:08 -0700
Subject: [Lustre-devel] rename in Changelog
In-Reply-To: <CALxHnhLjmB3QzY9m58iC-cWdRRcg9FX=Vw3GNHm+BEUFkLiTrg@mail.gmail.com>
References: <CALxHnhLjmB3QzY9m58iC-cWdRRcg9FX=Vw3GNHm+BEUFkLiTrg@mail.gmail.com>
Message-ID: <73AED5C780AE05478241DB067651A92102F109CD@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

it wasn't done that way in the first place because the record size in an llog is fixed,
so any size increase is multiplied by the number of records, so fewer records
can be stored.  Splitting the rename into two was the unfortunate casualty of that goal.

On Apr 25, 2012, at 2:05 AM, Lai Siyao wrote:

> Rename record in Changelog is different from other operations, it's split into
> two records: RNMFRM and RNMTO. This makes Changelog analysis hard
> because these two records may not be consecutive and several renames
> may occur at the same time.
> 
> I'm not clear why it's designed to be so, except that RNMTO is needed
> because for DNE (distributed namespace) the rename target may reside on
> another MDS, and a separate RNMTO record is needed. But even with this
> it's fine to store all information in a RENME record, but leave the information of
> whether rename removes the last hardlink of the target file (if it exists) in
> RNMTO record.
> 
> I tried to add a field spfid in struct changelog_rec to store source parent fid,
> and pack both source (if has) and target names into record. Normally the
> record size if sizeof(fid) larger than before, and it can be differentiated
> according to version. The test result looks good, but I want to know whether
> anyone oppose to this? If not, I'll make the change and make it changelog
> version 2.
> 
> Cheers,
> - Lai
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
