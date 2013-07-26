From: Alexey Zhuravlev <alexey.zhuravlev@intel.com>
Date: Fri, 26 Jul 2013 11:26:06 +0400
Subject: [Lustre-devel] Improving create rate with ZFS backed servers
In-Reply-To: <20130725175058.GU11789@llnl.gov>
References: <20130725175058.GU11789@llnl.gov>
Message-ID: <D5A739B6-B8C3-4065-87F7-E50F23BC2189@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jul 25, 2013, at 9:50 PM, Prakash Surya <surya1@llnl.gov> wrote:

> so I started by trying to figure out where the time was being spent in
> the precreate call path. On one of the OSS nodes I used ftrace to
> profile {{ofd_precreate_objects()}} and saw that it took a whopping 22
> seconds to complete for the specific call I was looking at! Digging a
> little deeper I saw many calls to {{dt_object_find()}} which would
> degenerate into {{fzap_lookup()}}'s and those into {{dbuf_read()}}
> calls. Some of these {{dbuf_read()}} calls took over 600ms to complete
> in the trace I was looking at. If we do a {{dt_object_find()}} for each
> object we're precreating, and each of those causes a {{dbuf_read()}}
> from disk which could take over half a second to complete, that's a
> recipe for terrible create rates.
> 
> Thus, the two solutions seem to be to either not do the
> {{fzap_lookup()}} altogether, or make the {{fzap_lookup()}} faster. One
> way to make it faster is to ensure the call is a ARC hit, rather than it
> reading from disk.

even if we remove lookups (which is possible), I don't think it will help much
because we still need to modify that leaf anyway (to add just created object
into OI), so read will be done few cycles later at declare.



thanks, Alex


--------------------------------------------------------------------
Closed Joint Stock Company Intel A/O
Registered legal address: Krylatsky Hills Business Park, 
17 Krylatskaya Str., Bldg 4, Moscow 121614, 
Russian Federation

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
