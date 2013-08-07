From: Tobias Groschup <groschup@stud.uni-heidelberg.de>
Date: Wed, 07 Aug 2013 12:48:04 +0200
Subject: [Lustre-devel] LND Development
Message-ID: <520225E4.1070000@stud.uni-heidelberg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

I am a student of applied Computer Science at the University of 
Heidelberg and I am  currently working on my master thesis about 
distributed file systems on networks capable of Remote Direct Memory Access.

I work at the Computer Architecture Group, which develops a High Speed 
Interconnect for High Performance Computing called Extoll. I have 
experience in developing Linux kernel modules, as I work on Extolls 
driver stack, including a kernel level API to access the Extoll device. 
Our aim is to implement a LND which supports Extoll.

So I started to build the current lustre-master and the patched kernel 
from scratch, which worked very well, thanks to the good documentation 
online.

After consulting the Lustre Manual, some guides and papers including 
"The Lustre Storage Architecture" and "Understanding Lustre Filesystem 
Internals"  I did not find an comprehensive overview for the API a LND 
has to implement. Although the function names are easy to find, its not 
clear what the expected behaviour of the function is, or with which 
ranges of input data they have to deal.

Also, the Doxygen generated from the LNet source files was not very helpful.

So my question is: where do I start to implement a LND?
And: how can I test a LND without recompiling the whole Lustre RPM?

Thanks
Tobias Groschup
