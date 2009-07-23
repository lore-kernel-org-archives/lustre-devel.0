From: Tuve Nordius <tuve@swedisk.se>
Date: Thu, 23 Jul 2009 10:00:56 +0200
Subject: [Lustre-devel] Mac OS and Windows clients
Message-ID: <689C4F2B-8759-4B61-B2ED-39BCC194608C@swedisk.se>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi

I am looking into developing mac os and windows clients and I have  
noticed that there have been some activities on this in the past and  
that native clients are in the roadmap for lustre and would like to  
get in contact with people who have been or planning to  be working on  
this.

The initial plan is to make liblustre compile on darwin and create a  
macfuse client. For the windows plattform there is some fuse like  
libraries, but I am unsure of the quality and status, maybe it is  
better to concentrate the effort on  bringing the winnt port up to date?

I have chosen the FreeBSD port of lustre (http://lustre.sev.net.ua/)  
as a starting point for liblustre and the source tree also contains  
some kind of fuse client, but i suspect this port is based on lustre  
1.6 ?

I also have some questions about the the OpenCVS, if just pulling HEAD  
there seem to be a lot of files related to darwin and winnt missing/ 
pruned, I have noticed that there is some tags APPLE_DEVELOP etc that  
pulls some of the darwin related files, but there is still some  
missing (xcode related), all of these files are present in the FreeBSD- 
tree, so the question basically is what version should i pull?

I have also noted that there is lot of documentation, which leaves me  
with the problem of where to start?



Best Regards

Tuve Nordius
