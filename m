From: Oleg Drokin <oleg.drokin@intel.com>
Date: Sun, 11 Feb 2018 19:52:26 -0500
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <87h8qnrt0o.fsf@notabene.neil.brown.name>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
 <09CE6CEC-52BC-4B29-B609-40DE68A64A33@intel.com>
 <87o9kylux7.fsf@notabene.neil.brown.name>
 <FC7E817D-BA15-4D0A-9976-F1343F9B022A@intel.com>
 <87h8qnrt0o.fsf@notabene.neil.brown.name>
Message-ID: <5928AEAA-EDD6-4A6E-A9BA-1FA5974C1BD9@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Feb 11, 2018, at 6:44 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Thu, Feb 08 2018, Oleg Drokin wrote:
>> 
>> Certain things that sound useless (like the debug subsystem in Lustre)
>> is very useful when you have a 10k nodes in a cluster and need to selectively
>> pull stuff from a run to debug a complicated cross-node interaction.
>> I asked NFS people how do they do it and they don?t have anything that scales
>> and usually involves reducing the problem to a much smaller set of nodes first.
> 
> the "rpcdebug" stuff that Linux/nfs has is sometimes useful, but some parts
> are changing to tracepoints and some parts have remained, which is a
> little confusing.
> 
> The fact that lustre tracing seems to *always* log everything so that if
> something goes wrong you can extract that last few meg(?) of logs seems
> really useful.

Not really. Lustre also has a bitmask for logs (since otherwise all those prints
are pretty cpu taxing), but what makes those logs better is:
the size is unlimited, not constrained by dmesg buffer size.
You can capture those logs from a crashdump (something I really wish
somebody would implement for tracepoint buffers, but alas, I have not
found anything for this yet - we have a crash plugin to extract lustre
debug logs from a kernel crashdump).
>>> 
>>> Even if it is horrible it would be nice to have it in staging... I guess
>>> the changes required to ext4 prohibit that... I don't suppose it can be
>>> made to work with mainline ext4 in a reduced-functionality-and-performance
>>> way??
>> 
>> We support unpatched ZFS as a server too! ;)
> 
> So that that mean you would expect lustre-server to work with unpatched
> ext4? In that case I won't give up hope of seeing the server in mainline
> in my lifetime.  Client first though.

While unpatched ext4 might in theory be possible, currently it does not export
everything we need from the transaction/fs control perspective.

Bye,
    Oleg
