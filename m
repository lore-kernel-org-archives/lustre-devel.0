From: Patrick Farrell <paf@cray.com>
Date: Sat, 15 Dec 2018 16:48:09 +0000
Subject: [lustre-devel] Latest build artifacts from build.whamcloud.com
 - Log in?
In-Reply-To: <B7C39AB4-931E-4BAC-A09F-0CECE3DC79B0@ddn.com>
References: <MWHPR11MB1488CD3EBDAB67229C9CA7EBCBA20@MWHPR11MB1488.namprd11.prod.outlook.com>
 <123395C5-27E2-4962-84C3-E1219A492D98@whamcloud.com>
 <MWHPR11MB14880CF67A748A7FEC74115ECBA20@MWHPR11MB1488.namprd11.prod.outlook.com>,
 <B7C39AB4-931E-4BAC-A09F-0CECE3DC79B0@ddn.com>
Message-ID: <MWHPR11MB1488DB5295F0A4FE32B65DE0CBA20@MWHPR11MB1488.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Ok, that explains it.  Thanks for the explanation.
________________________________
From: Peter Jones <pjones@whamcloud.com>
Sent: Saturday, December 15, 2018 10:11:03 AM
To: Patrick Farrell
Cc: Lustre Development List
Subject: Re: Latest build artifacts from build.whamcloud.com - Log in?


That one is not *always* covered but had been deliberately included during the window between RHEL 7.6 coming out and Centos 7.6 coming out. It could be removed now, obviously.



From: Patrick Farrell <paf@cray.com>
Date: Saturday, December 15, 2018 at 8:09 AM
To: Peter Jones <pjones@whamcloud.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Subject: Re: Latest build artifacts from build.whamcloud.com - Log in?



Ah, understood.

Should this include the kernel source RPM for the patched server kernel?  It appeared to when I tried last night, though I will give it another shot (as I may have been mistaken).


________________________________

From: Peter Jones <pjones@whamcloud.com>
Sent: Friday, December 14, 2018 11:11:11 PM
To: Patrick Farrell
Cc: Lustre Development List
Subject: Re: Latest build artifacts from build.whamcloud.com - Log in?



It?s only the zfs binaries that are restricted. If you download the files one by one you can get at the ones you need. This is a side-effect of Auto Test requiring access to these files but there being concerns about distributing then. We?re hoping to remove this long standing workaround in thev2.13 cycle

On Dec 14, 2018, at 7:36 PM, Patrick Farrell <paf at cray.com<mailto:paf@cray.com>> wrote:

Good evening,



This is mostly directed to Peter, but I thought it would be useful to others on this list.



I was hoping to snag some of the latest build artifact from build.whamcloud.com<http://build.whamcloud.com>, but I'm finding that to download most of them, it's asking for me to log in.  If I ever had an account here, I've long since lost it, and I don't see a way to request one.



So: What can I do to get access to these?  Is that even possible for non-Whamcloud folks any more?

Thanks!
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181215/5efe761f/attachment-0001.html>
