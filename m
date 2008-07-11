From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 11 Jul 2008 16:12:36 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <48777021.4030001@cea.fr>
Message-ID: <C49D36F4.63DF%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 7/11/08 8:37 AM, "Jacques-Charles Lafoucriere" <jc.lafoucriere@cea.fr>
wrote:

> Hello
> 
> following latest discussions I understand a large change is coming on
> Lustre/HSM interactions.
> In the HLD the HSM is following Lustre requests :
> - lustre triggers copy-out and copy-in

We can feed a list to the coordinator also to pre-stage ("primary versions")

> - all the copy requests are made through the coordinator control (so the
> Hsm_copy_to_fs command is a command line interface to the coordinator).

No.  I think we need to design this, but it will sipmly create a new file in
the file system, that doesn't require a coordinator.

> Note that this Hsm_copy_to_fs is different from the copy tool.
> The central role of coordinator allows us to control all the requests
> and avoid duplicated requests to copy tool (and give a global view).

The coordinator will do copy in form kernel, automatically triggered by
cache miss or by feeding a list to restore HSM primary copies.  The
hsm_copy_to_fs tool is ONLY needed when secondary copies held in the HSM are
being restored.


> 
> Now it seems Lustre will have to be able to follow HSM requests to send
> file back in Lustre and so independently of the coordinator (in a
> previous email it was requested Hsm_copy_to_fs to trigger copy
> independently of Lustre)
> I do not agree on this change because HSM has to be seen as a backend
> storage for Lustre and the decisions to copy have to be in Lustre.
> Lustre must no suffer HSM but must use it

No - I think you perhaps misunderstood the proposal.


> 
> To manage this new requirement the copy tool has to implement a central
> entity that will :
> - avoid duplicate requests
> - choose which agent has to make the copy
> This will have to be duplicated for each HSM (or backend) supported and
> also will duplicate coordinator role so I think it is better to have it
> in Lustre instead of in the copy tool.

No.

> 
> About file grouping, the planed features are :
> - for copy out:  in one request a list of files can be provided to copy
> tool so it can choose to group them in one HSM "group archive".

This again just rephrasing my question.  HOW is a list of small files
formed?

> - for copy in: if a file is in a HSM "group archive", the copy tool will
> copy back this file in Lustre (and not all the archive file)

No, because with your proposal restoring a 1000 small files will cause 1000
tape actions to get the archive.  I think the entire archive should come
back in one blow.

> - grouped request can come from a user request or a the space manager
> (for a generic policy)

Yes, how is the metadata handled?  This is the case where the HSM DB does
see significant load to make a mapping for each lustre fid to the archived
file.

> 
> The space manager design is today on stand by because of the lack of
> information on changelogs, feeds, Lustre policy engine

We will get there shortly.

> 
> I think there is a very strong need in Lustre to have a generic policy
> database that can be used to allocate files, copy out files, purge
> files, choose which agent will copy files .....

Policy database yes, but NOT a database with HSM related data.

There is a secondary side of policy which is how to treat the data that is
held in the HSM and that doesn't belong in Lustre, but belongs in user
space.  

Yet, this should be two parts of one policy management interface.  If Lustre
runs with Sun HSM it would be one tool, if Lustre runs with HPSS the tool
would have two sides - one to Lustre from Sun and one to HPSS from the HPSS
community.

> One use case for this database is to provide users an interface to said
> : I want all my *.avi files to be striped on 6 OST and all other files
> to be not striped

That is not an HSM policy, this should be a pool data placement policy and I
agree we need it.  The HSM should have sufficient metadata to restore files
in this manner if bare metal restore takes place.

The good news is that I see no serious disagreements, just some minor
misunderstandings.  Agree?

Happy quartorze juillet!!

Regards

Peter


> 
> JC
> 
> 
