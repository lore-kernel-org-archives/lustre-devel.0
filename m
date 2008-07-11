From: Jacques-Charles Lafoucriere <jc.lafoucriere@cea.fr>
Date: Fri, 11 Jul 2008 16:37:21 +0200
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <C49A1E05.4E85%peter.braam@sun.com>
References: <C49A1E05.4E85%peter.braam@sun.com>
Message-ID: <48777021.4030001@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

following latest discussions I understand a large change is coming on 
Lustre/HSM interactions.
In the HLD the HSM is following Lustre requests :
- lustre triggers copy-out and copy-in
- all the copy requests are made through the coordinator control (so the 
Hsm_copy_to_fs command is a command line interface to the coordinator).
Note that this Hsm_copy_to_fs is different from the copy tool.
The central role of coordinator allows us to control all the requests 
and avoid duplicated requests to copy tool (and give a global view).

Now it seems Lustre will have to be able to follow HSM requests to send 
file back in Lustre and so independently of the coordinator (in a 
previous email it was requested Hsm_copy_to_fs to trigger copy 
independently of Lustre)
I do not agree on this change because HSM has to be seen as a backend 
storage for Lustre and the decisions to copy have to be in Lustre.
Lustre must no suffer HSM but must use it

To manage this new requirement the copy tool has to implement a central 
entity that will :
- avoid duplicate requests
- choose which agent has to make the copy
This will have to be duplicated for each HSM (or backend) supported and 
also will duplicate coordinator role so I think it is better to have it 
in Lustre instead of in the copy tool.

About file grouping, the planed features are :
- for copy out:  in one request a list of files can be provided to copy 
tool so it can choose to group them in one HSM "group archive".
- for copy in: if a file is in a HSM "group archive", the copy tool will 
copy back this file in Lustre (and not all the archive file)
- grouped request can come from a user request or a the space manager 
(for a generic policy)

The space manager design is today on stand by because of the lack of 
information on changelogs, feeds, Lustre policy engine

I think there is a very strong need in Lustre to have a generic policy 
database that can be used to allocate files, copy out files, purge 
files, choose which agent will copy files .....
One use case for this database is to provide users an interface to said 
: I want all my *.avi files to be striped on 6 OST and all other files 
to be not striped

JC
