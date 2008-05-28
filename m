From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Wed, 28 May 2008 20:22:41 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <1211987642.4740.10.camel@localhost>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
	<1211987642.4740.10.camel@localhost>
Message-ID: <18493.34513.370736.111492@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ricardo M. Correia writes:
 > On Qua, 2008-05-28 at 18:54 +0400, Nikita Danilov wrote:
 > 
 > > But that problem has to be solved anyway to implement per-user quotas
 > > for ZFS, correct?
 > 
 > 
 > Indeed, but it's probably easier and more reliable to make the DMU
 > itself update an internal quota/space accounting DMU object when a txg
 > is syncing (updating internal objects during txg sync is something that
 > the DMU already does, e.g., for spacemaps) than allow arbitrary
 > modifications to a transaction group after it has been closed.

Even doing it internally looks rather involved. The problem, as I
understand it, is that no new block can be allocated while transaction
group is in sync state (?), so DMU would have to track all users and
groups whose quota is affected by the current transaction group, and
before closing the group, to allocate some kind of on-disk table with an
entry for every updated quota, then to fill these entries later when
actual disk space is allocated.

Note that dmu has to know about users and groups to implement quota
internally, which looks like a pervasive interface change.

 > 
 > I agree that quotas could be implemented in Lustre (independent of the
 > backend filesystem), but IMHO I think it would make more sense for the
 > space accounting to be done in the DMU itself due to the complexities
 > associated with it's internal behaviour.

I absolutely agree that DMU has to do space _accounting_ internally. The
question is how to store results of this accounting, without bothering
DMU with higher level concepts such as a user or a group identifier.

I think that utility of DMU as a universal back-end would improve if it
were to export an interface allowing its users to update, with certain
restrictions, on-disk state when transaction group is in sync (i.e.,
interface similar to one that is internally used for spacemaps).

 > 
 > Regards,
 > Ricardo

Nikita.
