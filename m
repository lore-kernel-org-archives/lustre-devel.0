From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 18 Aug 2015 11:00:23 -0700
Subject: [lustre-devel] lctl conf_param vs set_param -P
In-Reply-To: <CAB_j=MfmkTWAgLbY=QqyOiUVi6s=zn7aH+SZdSUEBjK5q+=3SA@mail.gmail.com>
References: <CAO3qy=GCE1fHkOk9Zn8HgdFpZy8FRb5S9y=6Wth8nHyReZWL9A@mail.gmail.com>	<55D2229A.10506@llnl.gov>
	<CAB_j=MfmkTWAgLbY=QqyOiUVi6s=zn7aH+SZdSUEBjK5q+=3SA@mail.gmail.com>
Message-ID: <55D372B7.1080700@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 08/17/2015 08:37 PM, Nathan Rutman wrote:
> The goal of set_param -P (permanent, global) was to replace conf_param
> and harmonize with set_param (local). (conf_param semantics were the
> beginning of an aborted attempt to move away from /proc and toward a
> more rational parameter space.) Unfortunately, most of the conf_param
> items were "specials", that had to be re-implemented under set_param -P.
> Most of that work was done years ago, but some things like "jobid" were
> not around then -- and apparently were implemented using the older
> mechanism only.

Could you elaborate on how jobid is special?  Why, set_param -P not 
currently knowing that jobid is special, is it not simply triggering the 
upcall on all nodes to write a value to the proc file?

How would a system administrator know which things are special and which 
are not, and how the behavior changes for special and non-special options?

Chris
