From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Thu, 02 Dec 2010 15:22:58 +0100
Subject: [Lustre-devel] Cannot easily build from master source anymore
In-Reply-To: <DA432BB3-C1EC-433B-8936-923B98D7C446@oracle.com>
References: <4CF6209A.6020401@cea.fr>
	<alpine.LFD.2.00.1012011944370.22096@casper.infradead.org>
	<DA432BB3-C1EC-433B-8936-923B98D7C446@oracle.com>
Message-ID: <4CF7ABC2.3000400@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger a ?crit :
> On 2010-12-01, at 12:45, James Simmons wrote:
>>> I noticed there was a refactor for packaging and versioning in Lustre 
>>> prime master branch.
>>> Unfortunately, we cannot simply do anymore
>>>
>>> git clone ...
>>> sh ./autogen.sh
>>> ./configure ..
>>> make
>>>
>>> to build lustre source
>>>
>>> What's the trick now ?
>>> Maybe it could be useful to update Wiki page: 
>>> http://wiki.lustre.org/index.php/Building_Lustre_Code
>> Let me guess. 
>>
>> checking for stdint.h... yes
>> checking for unistd.h... yes
>> checking whether to configure just enough for make dist... no
>> checking for buildid... configure: error: most recent tag found: v2_0_0 
>> does not match current version 2.0.56.
>> make: *** No rule to make target `rpms'.  Stop.
>> make: *** No rule to make target `rpms'.  Stop.
> 
> My recollection from Brian's previous postings is that this is somehow related to an old "git" version being used.

We are using either git v1.5.5.6. Is this so old?

> That said, I'd be happy to remove this as a requirement, and just stick with the version if there is a mismatch, printing only a warning if the git version is too old.

I think it will be a good idea



-- 
Aurelien Degremont
CEA
