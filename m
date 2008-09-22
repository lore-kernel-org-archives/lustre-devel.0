From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 22 Sep 2008 11:26:55 +0400
Subject: [Lustre-devel] Doubly indexed tree / changelogs
In-Reply-To: <C4FD66B7.7CDA%peter.braam@sun.com>
References: <C4FD66B7.7CDA%peter.braam@sun.com>
Message-ID: <48D748BF.1030404@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam wrote:
> Sure, when aggregations apply.  But they do not apply in general (e.g.
> Filesets that are search results) and we need a doubly indexed tree for
> that.

ah, clear enough

> Hence my question, what doubly indexed trees exist?

there is K-D tree, but I'm not sure it fits here.

if number of filesets is limited, then we probably could build a table of
all possible filesets ovelapping and put table's index into inode? this is
for reverse mapping to find all filesystems for given inode.


thanks, Alex
