From: Faaland, Olaf P. <faaland1@llnl.gov>
Date: Wed, 13 Apr 2016 21:22:25 +0000
Subject: [lustre-devel] LMT 3.2 - MDT display
In-Reply-To: <D3342841.40D82%thcrowe@iu.edu>
References: <D3342841.40D82%thcrowe@iu.edu>
Message-ID: <43111FD6D3DBA74A9134F6C11536F04ACBE2D75D@PRDEXMBX-08.the-lab.llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Tim,

It sounds like maybe you see the summary and the OST list, but not the MDT list.

The ltop display has 3 different components:
[ summary ]
[ mdt list ]
[ ost list ]

The summary at the top has all the fields displayed in the mdt list; so if you have only 1 MDT, then it doesn't waste the screen space used by an MDT list, and just shows
[summary]
[ ost list    ]

Does that explain it?

thanks,
Olaf P. Faaland
Livermore Computing
phone : 925-422-2263
________________________________
From: lustre-devel [lustre-devel-bounces at lists.lustre.org] on behalf of Crowe, Tom [thcrowe at iu.edu]
Sent: Wednesday, April 13, 2016 1:45 PM
To: lustre-devel at lists.lustre.org
Subject: [lustre-devel] LMT 3.2 - MDT display

Greetings,

After seeing a presentation at LUG16 (http://cdn.opensfs.org/wp-content/uploads/2016/04/LUG2016D1_LMT-Only-a-Flesh-Wound_Faaland.pdf), I was excited to try the updated version of LMT (3.2) as it appeared detailed MDT/MDS information is included in ltop output.

I have successfully built and installed LMT 3.2, but there is no display of MDT info.

Wondering how I might troubleshoot this further. Everything is working, its just not giving me the MDT/MDS info as I expected it might.

Thanks,
Tom Crowe
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160413/7169c9c2/attachment.htm>
