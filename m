From: James Simmons <jsimmons@infradead.org>
Date: Fri, 23 Mar 2018 03:26:58 +0000 (GMT)
Subject: [lustre-devel] lustre and loopback device
Message-ID: <alpine.LFD.2.21.1803222322450.17346@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hi Neil

      So once long ago lustre had its own loopback device due to the 
upstream loopback device not supporting Direct I/O. Once it did we
dropped support for our custom driver. Recently their has been interest
in using the loopback driver and Jinshan discussed with me about reviving
our custom driver which I'm not thrilled about. He was seeing problems
with Direct I/O above 64K. Do you know the details why that limitation
exist. Perhaps it can be resolved or maybe we are missing something?
Thanks for your help.
