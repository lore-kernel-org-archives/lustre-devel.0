From: Degremont, Aurelien <degremoa@amazon.com>
Date: Tue, 5 Feb 2019 17:09:23 +0000
Subject: [lustre-devel] Run acceptance tests on client side only
In-Reply-To: <10A6B545-A2DD-4DB7-A8DE-6FFE2D174A6A@whamcloud.com>
References: <9E0B8A72-3AFF-4141-8E94-28AF402B0CC9@amazon.com>
 <10A6B545-A2DD-4DB7-A8DE-6FFE2D174A6A@whamcloud.com>
Message-ID: <61A33E81-F7E8-450B-A3A5-81D52B4A1E95@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks Andreas for this info.
I will look at the scripts and see if we want to go deeper in this direction.

Aur?lien

?Le 04/02/2019 08:37, ? Andreas Dilger ? <adilger@whamcloud.com> a ?crit :

    On Jan 30, 2019, at 07:53, Degremont, Aurelien <degremoa@amazon.com> wrote:
    > 
    > Hello
    >  
    > I?m trying to run test suites without having access to servers.
    > A lot of tests in acc-sm assume that servers are reachable. Is there way to automatically skip these tests?
    >  
    > Does somebody has a smart way to run acc-sm?
    
    Aurelien,
    at one time in the past it was possible to run sanity and runtests only on the client by setting "CLIENTONLY=yes". However, this isn't commonly used so is likely missing from a bunch of subtests.
    
    There are also checks in some subtests "remote_mds_nodsh" and/or "remote_ost_nodsh" to skip tests that depend on remote access to the servers when the MDS is not accessible from the client.  This is not _exactly_ the same as CLIENTONLY in that they are still run if the MDS/OSS are running on the same node as the client.
    
    If running tests in this manner is of interest to you, patches would be welcome to add test skips as needed to get this working again.
    
    Cheers, Andreas
    ---
    Andreas Dilger
    Principal Lustre Architect
    Whamcloud
    
    
    
    
    
    
    
    
