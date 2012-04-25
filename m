From: Lai Siyao <laisiyao@whamcloud.com>
Date: Wed, 25 Apr 2012 15:05:46 +0800
Subject: [Lustre-devel] rename in Changelog
Message-ID: <CALxHnhLjmB3QzY9m58iC-cWdRRcg9FX=Vw3GNHm+BEUFkLiTrg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Rename record in Changelog is different from other operations, it's split
into
two records: RNMFRM and RNMTO. This makes Changelog analysis hard
because these two records may not be consecutive and several renames
may occur at the same time.

I'm not clear why it's designed to be so, except that RNMTO is needed
because for DNE (distributed namespace) the rename target may reside on
another MDS, and a separate RNMTO record is needed. But even with this
it's fine to store all information in a RENME record, but leave the
information of
whether rename removes the last hardlink of the target file (if it exists)
in
RNMTO record.

I tried to add a field spfid in struct changelog_rec to store source parent
fid,
and pack both source (if has) and target names into record. Normally the
record size if sizeof(fid) larger than before, and it can be differentiated
according to version. The test result looks good, but I want to know whether
anyone oppose to this? If not, I'll make the change and make it changelog
version 2.

Cheers,
- Lai
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120425/e2f038d1/attachment.htm>
