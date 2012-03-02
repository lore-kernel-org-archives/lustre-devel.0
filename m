From: DENIEL Philippe <philippe.deniel@cea.fr>
Date: Fri, 02 Mar 2012 13:25:20 +0100
Subject: [Lustre-devel] Does LUSTRE supports setfsuid/setfsgid ?
Message-ID: <4F50BC30.5090602@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi List,

I am the maintener of NFS-Ganesha, a NFS server running in User Space. 
The server has several backends on different filesystems. One of the 
backend is dedicated to LUSTRE, using liblustreapi.a .
The server is generic and I faced the problem to "su" to a user inside a 
thread for backends whose calls have no specific credentials parameter. 
For backends like XFS, GPFS and VFS (they are accessed via the "open by 
handle" feature in kernel > 2.6.39) I can use setfsuid/setfsgid. I works 
pretty well and provides a way to "become" a different user in different 
threads. I plan to use the same kind of logic with LUSTRE.
Here comes my question : does LUSTRE supports setfsuid and setfsgid and 
it behaves a every filesystem accessed by the VFS ?

    Regards

       Philippe
