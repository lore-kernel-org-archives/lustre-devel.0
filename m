From: Robert Read <rread@Sun.COM>
Date: Mon, 23 Jun 2008 16:24:33 -0700
Subject: [Lustre-devel] ongoing libcfs changes
Message-ID: <E1353AC0-69BF-4C59-8744-994AE73C10D3@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I just want to let everyone that we are starting to cleanup libcfs,  
and recently it was moved out of lnet into it's own top level  
directory. We will be refactoring the code over the next couple of  
months to make it easier to port the library. Initially we will try to  
minimize the impact on the rest of the code, but eventually we'll  
start renaming functions (as well as the library, at some point) and  
that will cause some widespread changes. If you have any questions or  
comments about what are doing, please let me know.

robert
