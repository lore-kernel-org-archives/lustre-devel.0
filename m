From: Artem Blagodarenko <artem.blagodarenko@seagate.com>
Date: Mon, 17 Aug 2015 19:10:59 +0300
Subject: [lustre-devel] lctl conf_param vs set_param -P
Message-ID: <CAO3qy=GCE1fHkOk9Zn8HgdFpZy8FRb5S9y=6Wth8nHyReZWL9A@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

>Can someone offer any insight on why the behavior appears to be different
or provide insight on if this is incorrect behavior

"set_param -P" command syntax is differ from "conf_param" by design. It is
same as "set_param" syntax. This allows use "set_param" for temporary
commands and "set_param -P" for permanent. "set_param -P" allows change the
same parameters that "set_param". So command set is wider, BUT existing
commands should be changed to qualify "set_param" syntax. Below is the
example:
[root at devvm-sl6-1 MRP-2661]# lctl get_param jobid_var
jobid_var=disable

[root at devvm-sl6-1 MRP-2661]# lctl set_param -P client.jobid_var=SLURM_JOB_ID

[root at devvm-sl6-1 MRP-2661]# lctl get_param jobid_var
jobid_var=SLURM_JOB_ID

>When using conf_param, any changes to the property are written to
/proc/fs/lustre/jobid_var within a short period of time. This is not the
case with set_param -P.

After "set_param -P" applied, lock for "params" file is canceled that
initiate this log is acquired and "executed" by targets and clients. This
requires some time.

>The change is never reflected nor is it stored in some other file within
/proc.

Changes stored in "params" file in CONFIG directory. Can be viewed using
log_reader.

>In short, it appears that conf_param attempts to apply the changes to all
the targets while set_param does not (it does not recognize it as a global
property).

Really "set_param -P" attempts to apply the new changes to all the targets
too. Command is executed on all targets, and all commands have "general" as
0th parameter of command in llog file params.

>Is it the intent of "set_param -P" that the specified changes only take
effect after components are restarted?  And if so, why?

No, changes applied just after command executed, but some time is required
to cancel lock for params file.

>How would a normal system administrator go about finding out what
settings are currently set permanently?

Seme settings as "set_param" sets can be set using "set_param -P". Finally
all command that stored using "set_param" executed using "lctl set_param"
upcall on targets.

From a user-interface standpoint though, presenting a single namespace
for all nodes in the entire center seems like less than desirable
choice.

Yes, probably. All commands are saved in one namespace. It called
"general". But I believe we could fix this issue easy, changing "general"
to filesystem name, so targets checks this namespace before executing
upcall.

Actually, command that have  filesystem part (for example started as
"testfs.") faintly failed on wrong nodes and succeed only on addressed
nodes. So probably, we do not need change this, but we can use reserved
field if we would.

>Given that not all paths
under /proc have differentiating strings in their path, there are some
things that can only be set completely globally in this design.

Yes, this is case there we could change "general" to filename. Or fix this
issue changing procfs paths.

>And what about sites that use an MGS per filesystem, rather than a
single MGS for the entire site?  If one MGS says that the debug level
should be one value, and another says that the debug value should be
another value, is it entirely random which debug setting will appear on
any given node?

Good example there we could use reserved field. Do you think this can solve
the issue? If so, we could extend "set_param -P" now.

>We might want to just remove the conf_param deprecation message
altogether.  I think there is more than just a simple bug in the
"set_param -P" implementation.

I believe we need move to "set_param -P". Yes, this require some scripts to
be changed, but fixing this now we get method with this benefits instead of
conf_param:
1. Identical format for permanent and temporary commands
2. wildcarding in strings
3. no unimplemented paths (e.g. ptlrpc services)
4. simpler implementation

From what I am seeing, it looks to me like we have some design issues.

All mentioned issues can be fixed easily without changing design. The
problem of namespace distinguish already is part of design. Special field
is reserved.

>Without anyone committed to working
out a better design and implementing it, set_param -P looks like
technical debt with no clear resolution in sight.  Maybe we should even
consider stripping it back back out of the tree.

I belive we could solve found issues and move forward using "set_param -P"
I offered "set_param -P topic to last LAD, but unfortunately it was not
accepted. Lets' discuss this together. Moving conf_param discarding date
forward gives us some time for this.

Thanks.

On Sat, Aug 15, 2015 at 11:04 PM, <lustre-devel-request@lists.lustre.org>
wrote:

> Send lustre-devel mailing list submissions to
>         lustre-devel at lists.lustre.org
>
> To subscribe or unsubscribe via the World Wide Web, visit
>
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwICAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=f-9bup-jYTTZb-zqZbdOzQTObV_VGrTP7-8xROGj35I&m=zc0hAFYXhRlbqxXHoLOSK0PoVteDFbf33MzwVDBMADY&s=NedsjGFvLB9S2GAZw1bC2c9WNT-N8YBC0YHvMimBTvw&e=
> or, via email, send a message with subject or body 'help' to
>         lustre-devel-request at lists.lustre.org
>
> You can reach the person managing the list at
>         lustre-devel-owner at lists.lustre.org
>
> When replying, please edit your Subject line so it is more specific
> than "Re: Contents of lustre-devel digest..."
>
>
> Today's Topics:
>
>    1. Re: lctl conf_param vs set_param -P (Christopher J. Morrone)
>    2. Re: lctl conf_param vs set_param -P (Dilger, Andreas)
>    3. Re: lctl conf_param vs set_param -P (Christopher J. Morrone)
>
>
> ----------------------------------------------------------------------
>
> Message: 1
> Date: Fri, 14 Aug 2015 13:41:03 -0700
> From: "Christopher J. Morrone" <morrone2@llnl.gov>
> To: lustre-devel at lists.lustre.org
> Subject: Re: [lustre-devel] lctl conf_param vs set_param -P
> Message-ID: <55CE525F.3020505@llnl.gov>
> Content-Type: text/plain; charset=windows-1252; format=flowed
>
> I too am confused.  And a bit dismayed that there is so little in the
> way of code comments to explain the intent.
>
> Is it the intent of "set_param -P" that the specified changes only take
> effect after components are restarted?  And if so, why?
>
> How would a normal system administrator go about finding out what
> settings are currently set permanently?
>
> I read through LU-3155 and see the discussion about using a single llog
> file for all nodes, so I will withhold comment about that for now.
>
>  From a user-interface standpoint though, presenting a single namespace
> for all nodes in the entire center seems like less than desirable
> choice.  Might we not want to set settings differently on different
> clusters (be they client or server clusters)?  Given that not all paths
> under /proc have differentiating strings in their path, there are some
> things that can only be set completely globally in this design.
>
> And what about sites that use an MGS per filesystem, rather than a
> single MGS for the entire site?  If one MGS says that the debug level
> should be one value, and another says that the debug value should be
> another value, is it entirely random which debug setting will appear on
> any given node?
>
> Chris
>
> On 08/13/2015 03:43 PM, Di Natale, Giuseppe wrote:
> > Greetings,
> >
> > In an effort to change test-framework.sh to not utilize the deprecated
> > conf_param option in lctl, I stumbled upon what appears to be
> > inconsistent behavior between lctl's conf_param and set_param -P
> > options. The permanent option test-framework.sh is attempting to change
> > is jobid_var. When using conf_param, any changes to the property are
> > written to /proc/fs/lustre/jobid_var within a short period of time. This
> > is not the case with set_param -P. The change is never reflected nor is
> > it stored in some other file within /proc. I started digging into the
> > MGS logs and found that the behavior for both are different (the
> > relevant segments of the logs are attached to this email and are named
> > accordingly). In short, it appears that conf_param attempts to apply the
> > changes to all the targets while set_param does not (it does not
> > recognize it as a global property). Can someone offer any insight on why
> > the behavior appears to be different or provide insight on if this is
> > incorrect behavior?
> >
> > Thanks,
> > Giuseppe Di Natale
> >
> >
> > _______________________________________________
> > lustre-devel mailing list
> > lustre-devel at lists.lustre.org
> >
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwICAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=f-9bup-jYTTZb-zqZbdOzQTObV_VGrTP7-8xROGj35I&m=zc0hAFYXhRlbqxXHoLOSK0PoVteDFbf33MzwVDBMADY&s=NedsjGFvLB9S2GAZw1bC2c9WNT-N8YBC0YHvMimBTvw&e=
> >
>
>
>
> ------------------------------
>
> Message: 2
> Date: Sat, 15 Aug 2015 00:07:22 +0000
> From: "Dilger, Andreas" <andreas.dilger@intel.com>
> To: "Di Natale, Giuseppe" <dinatale2@llnl.gov>
> Cc: "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
> Subject: Re: [lustre-devel] lctl conf_param vs set_param -P
> Message-ID: <D1F3DE3E.101528%andreas.dilger@intel.com>
> Content-Type: text/plain; charset="us-ascii"
>
> Coincidentally (or maybe that was what drove your investigations?), I'd
> just filed
> https://urldefense.proofpoint.com/v2/url?u=https-3A__jira.hpdd.intel.com_browse_LU-2D7004&d=AwICAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=f-9bup-jYTTZb-zqZbdOzQTObV_VGrTP7-8xROGj35I&m=zc0hAFYXhRlbqxXHoLOSK0PoVteDFbf33MzwVDBMADY&s=h6zLIi4EW2KHxq37PO71vZIbOskaw7V_qJJGV9mplo4&e=
> about this issue.  It looks like the "lctl set_param -P" feature needs more
> testing, and I've removed the deprecation warning for "lctl conf_param" for
> 2.8.
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Software Architect
> Intel High Performance Data Division
>
> On 2015/08/13, 4:43 PM, "lustre-devel on behalf of Di Natale, Giuseppe" <
> lustre-devel-bounces at lists.lustre.org<mailto:
> lustre-devel-bounces at lists.lustre.org> on behalf of dinatale2 at llnl.gov
> <mailto:dinatale2@llnl.gov>> wrote:
>
> Greetings,
>
> In an effort to change test-framework.sh to not utilize the deprecated
> conf_param option in lctl, I stumbled upon what appears to be inconsistent
> behavior between lctl's conf_param and set_param -P options. The permanent
> option test-framework.sh is attempting to change is jobid_var. When using
> conf_param, any changes to the property are written to
> /proc/fs/lustre/jobid_var within a short period of time. This is not the
> case with set_param -P. The change is never reflected nor is it stored in
> some other file within /proc. I started digging into the MGS logs and found
> that the behavior for both are different (the relevant segments of the logs
> are attached to this email and are named accordingly). In short, it appears
> that conf_param attempts to apply the changes to all the targets while
> set_param does not (it does not recognize it as a global property). Can
> someone offer any insight on why the behavior appears to be different or
> provide insight on if this is incorrect behavior?
>
> Thanks,
> Giuseppe Di Natale
>
>
> ------------------------------
>
> Message: 3
> Date: Fri, 14 Aug 2015 17:36:47 -0700
> From: "Christopher J. Morrone" <morrone2@llnl.gov>
> To: lustre-devel at lists.lustre.org
> Subject: Re: [lustre-devel] lctl conf_param vs set_param -P
> Message-ID: <55CE899F.5060403@llnl.gov>
> Content-Type: text/plain; charset=windows-1252; format=flowed
>
> It was coincidental this time.  We saw the deprecation message during
> llmount.sh and figured that might be an easy first task for Giuseppe to
> get familiarity with the patch submission process.  But it turned out to
> be a little more difficult than I thought. :)
>
> We might want to just remove the conf_param deprecation message
> altogether.  I think there is more than just a simple bug in the
> "set_param -P" implementation.  From what I am seeing, it looks to me
> like we have some design issues.  Without anyone committed to working
> out a better design and implementing it, set_param -P looks like
> technical debt with no clear resolution in sight.  Maybe we should even
> consider stripping it back back out of the tree.
>
> Chris
>
> On 08/14/2015 05:07 PM, Dilger, Andreas wrote:
> > Coincidentally (or maybe that was what drove your investigations?), I'd
> just filed
> https://urldefense.proofpoint.com/v2/url?u=https-3A__jira.hpdd.intel.com_browse_LU-2D7004&d=AwICAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=f-9bup-jYTTZb-zqZbdOzQTObV_VGrTP7-8xROGj35I&m=zc0hAFYXhRlbqxXHoLOSK0PoVteDFbf33MzwVDBMADY&s=h6zLIi4EW2KHxq37PO71vZIbOskaw7V_qJJGV9mplo4&e=
> about this issue.  It looks like the "lctl set_param -P" feature needs more
> testing, and I've removed the deprecation warning for "lctl conf_param" for
> 2.8.
> >
> > Cheers, Andreas
> > --
> > Andreas Dilger
> > Lustre Software Architect
> > Intel High Performance Data Division
> >
> > On 2015/08/13, 4:43 PM, "lustre-devel on behalf of Di Natale, Giuseppe" <
> lustre-devel-bounces at lists.lustre.org<mailto:
> lustre-devel-bounces at lists.lustre.org> on behalf of dinatale2 at llnl.gov
> <mailto:dinatale2@llnl.gov>> wrote:
> >
> > Greetings,
> >
> > In an effort to change test-framework.sh to not utilize the deprecated
> conf_param option in lctl, I stumbled upon what appears to be inconsistent
> behavior between lctl's conf_param and set_param -P options. The permanent
> option test-framework.sh is attempting to change is jobid_var. When using
> conf_param, any changes to the property are written to
> /proc/fs/lustre/jobid_var within a short period of time. This is not the
> case with set_param -P. The change is never reflected nor is it stored in
> some other file within /proc. I started digging into the MGS logs and found
> that the behavior for both are different (the relevant segments of the logs
> are attached to this email and are named accordingly). In short, it appears
> that conf_param attempts to apply the changes to all the targets while
> set_param does not (it does not recognize it as a global property). Can
> someone offer any insight on why the behavior appears to be different or
> provide insight on if this is incorrect behavio
>  r?
> >
> >
> > Thanks,
> > Giuseppe Di Natale
> > _______________________________________________
> > lustre-devel mailing list
> > lustre-devel at lists.lustre.org
> >
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwICAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=f-9bup-jYTTZb-zqZbdOzQTObV_VGrTP7-8xROGj35I&m=zc0hAFYXhRlbqxXHoLOSK0PoVteDFbf33MzwVDBMADY&s=NedsjGFvLB9S2GAZw1bC2c9WNT-N8YBC0YHvMimBTvw&e=
> >
>
>
>
> ------------------------------
>
> Subject: Digest Footer
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
>
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwICAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=f-9bup-jYTTZb-zqZbdOzQTObV_VGrTP7-8xROGj35I&m=zc0hAFYXhRlbqxXHoLOSK0PoVteDFbf33MzwVDBMADY&s=NedsjGFvLB9S2GAZw1bC2c9WNT-N8YBC0YHvMimBTvw&e=
>
>
> ------------------------------
>
> End of lustre-devel Digest, Vol 103, Issue 2
> ********************************************
>



-- 
Artem Blagodarenko Ph.D.*?* SW Developer on my.seagate.com
Seagate Technology, LLC
www.seagate.com
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150817/7c5d1935/attachment-0001.htm>
