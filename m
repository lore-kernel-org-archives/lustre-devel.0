From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Wed, 25 Mar 2009 19:17:29 +0300
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <m3y6uungs7.fsf@bzzz.home.net>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<200903251117.48986.alexander.zarochentsev@sun.com>
	<m3y6uungs7.fsf@bzzz.home.net>
Message-ID: <200903251917.30178.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 25 March 2009 11:33:12 Alex Zhuravlev wrote:
> >>>>> Alexander Zarochentsev (AZ) writes:
>
>  AZ> On 24 March 2009 02:17:33 Robert Read wrote:
>  >> Hi Zam,
>  >>
>  >> > MD update: a part of MD operation to be executed on one server,
>  >> > contains one or more MDS/RAW operations.
>  >>
>  >> Why does the client need to to be more granular than an update? 
>  >> It seems MDS/Raw and update should be the same.
>
>  AZ> well, better to say an update is MDS op if the operation touch
> only one AZ> MD server and MDS/Raw op in case of distributed
> operation.
>
>
> I think this just adds unneeded entity to the system. stating that
> we either have updates or operations is simpler.
>
>  >> Isn't this essentially what the cmm is doing today? (Breaking
>  >> down distributed operations into per-node updates?)  Are you
>  >> expanding on Alex's idea of creating a new generic MD server
>  >> stack?
>
>  AZ> I just doubt that cmm code reuse is worth MD stack relayering.
> Can it be AZ> done as a subtask later?
>
> I don't think CMM is right thing because it essentially breaks
> layering: instead of sending object creation request in terms of OSD
> API or index insert in terms of OSD API it introduces some
> intermediate thing which is neither operation nor update.

Server MD stack has to support both WBC and non-WBC clients for the same 
objects. It is why I think MDT layer should handle MD ops as well as 
MDS/RAW ops. Then CMM only passes RAW operations to MDD layer, where 
raw ops are already supported.

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
