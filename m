From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 21:35:33 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <DM3PR1101MB121322E85FDE1E5310F6F4B7CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
 <DM3PR1101MB1213DDB7FC857EE6B1444153CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
 <alpine.LFD.2.21.1806210354260.3886@casper.infradead.org>,
 <3FD4D051-9C95-449D-8A23-D42B271E55B8@dilger.ca>
 <DM3PR1101MB121322E85FDE1E5310F6F4B7CB760@DM3PR1101MB1213.namprd11.prod.outlook.com>
Message-ID: <alpine.LFD.2.21.1806242134170.28698@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Ah, thanks Andreas.? Perhaps not coincidentally, Lustre 2.4 is the first release I worked on.
> 
> Neil, I am really unenamored of the idea of the shared ptlrpc ldlm module being named ptlrpc...
> 
> Also, Lustre currently has a bunch of module parameters which are used for configuration.? Thoughts on that?

Currently ldlm is built into the ptlrpc module for the OpenSFS branch. 
Are you suggesting a different approach?
