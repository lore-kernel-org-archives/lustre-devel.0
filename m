From: James Simmons <jsimmons@infradead.org>
Date: Wed, 1 Dec 2010 19:45:07 +0000 (GMT)
Subject: [Lustre-devel] Cannot easily build from master source anymore
In-Reply-To: <4CF6209A.6020401@cea.fr>
References: <4CF6209A.6020401@cea.fr>
Message-ID: <alpine.LFD.2.00.1012011944370.22096@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Hello
> 
> I noticed there was a refactor for packaging and versioning in Lustre 
> prime master branch.
> Unfortunately, we cannot simply do anymore
> 
> git clone ...
> sh ./autogen.sh
> ./configure ..
> make
> 
> to build lustre source
> 
> What's the trick now ?
> Maybe it could be useful to update Wiki page: 
> http://wiki.lustre.org/index.php/Building_Lustre_Code

Let me guess. 

checking for stdint.h... yes
checking for unistd.h... yes
checking whether to configure just enough for make dist... no
checking for buildid... configure: error: most recent tag found: v2_0_0 
does not match current version 2.0.56.
make: *** No rule to make target `rpms'.  Stop.
make: *** No rule to make target `rpms'.  Stop.
