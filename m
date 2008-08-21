From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Thu, 21 Aug 2008 13:24:08 +0400
Subject: [Lustre-devel]  [RFC] "lctl readonly" modification proposal
In-Reply-To: <op.uf7ac4keatmt0c@goga>
References: <C4D1B2E1.575A%peter.braam@sun.com> <op.uf7ac4keatmt0c@goga>
Message-ID: <200808211324.09313.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 20 August 2008 23:42:39 Mikhail Pershin wrote:
> On Wed, 20 Aug 2008 21:39:13 +0400, Peter Braam <Peter.Braam@sun.com>
>
> wrote:
> > If I remember correctly the flush is only there to try to reduce
> > rollback.
>
> Also to be sure that all before barrier is on disk, many test cases
> about recovery rely on the fact that operations before barrier are on
> disk. This is important with HARD failure case especially, without
> sync before barrier the operations before barrier may be lost and
> affect the tests. I agree that syncless variant of barrier is needed
> but we also need barrier with sync depending on test case.

You don't need lctl readonly to do a sync, the replay_barrier function 
from test-framework.sh adds a sync explicitly:

replay_barrier() {
    local facet=$1
    do_facet $facet sync
    df $MOUNT
    local svc=${facet}_svc
    do_facet $facet $LCTL --device %${!svc} readonly
    do_facet $facet $LCTL --device %${!svc} notransno
    do_facet $facet $LCTL mark "$facet REPLAY BARRIER on ${!svc}"
    $LCTL mark "local REPLAY BARRIER on ${!svc}"
}

WBR,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
