From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 02 Aug 2013 13:21:17 -0700
Subject: [Lustre-devel] ldiskfs build system changes
Message-ID: <51FC14BD.7060400@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi folks,

I want to make people aware of the following ldiskfs patch that I have 
under review:

   http://review.whamcloud.com/6850

I don't suspect that anyone other than LLNL has been building ldiskfs 
externally to lustre.  This patch will remove the ability to do 
"--with-ldiskfs=/some/other/location".

My best guess is that no one other than LLNL is effected by this change. 
  With the rest of the changes to the ldiskfs build system and packaging 
made by this patch, LLNL will be happy to stop using that option.

But folks should be aware of that change.  If that change will impact 
you negatively, please let me know.  We'll work out a solution that will 
work for everyone.

Chris
