From: Alex Kulyavtsev <aik@fnal.gov>
Date: Tue, 25 Nov 2008 10:59:10 -0600
Subject: [Lustre-devel] HSM arch wiki
In-Reply-To: <48FD0F98.9040300@sun.com>
References: <48EE87A1.7000003@sun.com> <48F379B4.6040209@cea.fr>
	<48FD0F98.9040300@sun.com>
Message-ID: <492C2EDE.70507@fnal.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Few questions :
- For large existing archive of tapes (~10,000,000 files) it is 
desirable to import file metadata to lustre fs without actually copying 
files on disk.
Import shall be done in reasonable time (hours rather than month) or online.

- to provide bandwidth to tape it is desirable to have multiple migrator 
nodes connected to HSM. What element of proposed design distributes 
copy-out processes across migrator nodes to provide scalability ? Is it 
functionality of HSM specific copy tool or does lustre agent provide it ?

- a "smart" HSM system can reorder requests to optimize tape access. It 
is common to have 2000 requests pending in queue with tens or hundreds 
IO transfers actually served. Current limit of pending requests is about 
30,000. We found implementing of pending requests as processes (one 
copy-out tool process per request waiting for IO) is resource consuming 
and is not scalable. What is the way to serve ~100,000 request waiting 
for transfer ?

- how to prestage files ? Send asynchronous request for copy-in file 
from tape without blocking on wait. It is needed to stage large data 
sets for future processing. Prestaging "file sets" is desirable.

- what proposed scanario to handle OST down ? Suppose file is present on 
one of OSTs and it went down (striping is one). My understanding is 
client will wait when OST will come back (case[1]) and file will not be 
staged from tape automatically. IF file is not present on any OST, it 
will be staged immediately (case[2]). Is possible to stage file 
automatically (case[1]) to another OST and mark a copy on old OST for 
removal ?

We discussed some of these questions with Peter, he suggested to ask on 
devel list.

Best regards, Alex.

Nathaniel Rutman wrote:
> High-level architecture page for the Lustre HSM project
> http://arch.lustre.org/index.php?title=HSM_Migration
>
>
> HSM core team - this is intended to be sufficient to write a full 
> HLD/DLD from.  What is it missing?
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
