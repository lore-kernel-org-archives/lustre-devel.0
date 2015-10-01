From: Olaf Weber <olaf@sgi.com>
Date: Thu, 1 Oct 2015 16:31:56 +0200
Subject: [lustre-devel] Channel Bonding Debug Information
In-Reply-To: <CAAqp6i2jWQheq7aeT+VkQ5+=JsuAuMTJSPewGAfvaC8r8kSf9Q@mail.gmail.com>
References: <CAAqp6i2jWQheq7aeT+VkQ5+=JsuAuMTJSPewGAfvaC8r8kSf9Q@mail.gmail.com>
Message-ID: <560D43DC.2080600@sgi.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 28-09-15 21:30, Amir Shehata wrote:
> Hello,
>
> As a followup on the discussion in the LAD developer summit, regarding
> ensuring that there is enough debug information provided as part of the
> Channel Bonding solution, I'm sending this email to ask for ideas on what
> type of debug information you would like to see.
>
> thanks
> amir

Hi Amir,

My random and disorganized thoughts.

Significant state changes and anything unexpected should of course be logged.

In addition I'd like interfaces that allow me to efficiently get the 
status/stats of a specific network interface or a specific peer, as opposed 
to only being able to get the information for all interfaces or peers and 
then having to filter. That may imply an ioctl type interface instead of or 
in addition to debugfs or sysfs (or procfs).

For the local interfaces, stats include TX/RX counters, credits, interface 
state, and some measure of how busy the interface is. The latter can be 
derived by watching the TX/RX counters over time, but it would be nice to 
have it calculated. A variant on the "File Heat" idea presented at LAD might 
work for this. (Think decaying sum over recent activity.) When interfaces 
are associated with CPTs, the CPT number -- especially important if the 
kernel automatically associates an interface with a CPT.

For the peers, a way to obtain the list of peers, and then to obtain the 
interfaces for each peer. Stats per peer interface include TX/RX counters 
and credits, perceived health, and maybe "heat". For a peer itself possibly 
totals, and peer health as perceived by the current node.

A note on calculating heat: the full list of peer interfaces becomes large 
(on the servers of a large cluster) and you don't want to walk it without 
needing to. If you store a timestamp for the last use, then heat can be 
calculated when the TX/RX counters are updated or read, which is when the 
relevant datastructure is being accessed anyway.

For local interfaces the list is likely small enough that this kind of 
approach isn't worth it. Moreover the list of local interfaces might be 
regularly walked to check on health etc.

Olaf

-- 
Olaf Weber                 SGI               Phone:  +31(0)30-6696796
                            Veldzigt 2b       Fax:    +31(0)30-6696799
Sr Software Engineer       3454 PW de Meern  Vnet:   955-6796
Storage Software           The Netherlands   Email:  olaf at sgi.com
