From: Cory Spitz <spitzcor@cray.com>
Date: Wed, 23 May 2018 04:15:55 +0000
Subject: [lustre-devel] Lustre client out of staging
Message-ID: <AEF585EB-196F-4B33-B447-A28FD68A2F57@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello, all.

I think we need a new subject for this conversation.

On 5/22/18, 7:57 PM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:
    
    My main thought is that it is crazy that we have the client in Linux but
    not the server.  However that ship obviously sailed long ago.  One of my
    first priorities after getting lustre-client out of staging will be to
    get lustre-server into staging. It makes zero sense to develop them
    separately.

And neilb at suse.com wrote:
    
    The path out of staging is to remove all the warts we can find, address
    all the issues that have been raised in the past, then say "please".
    If people don't see things they hate, they'll probably just shrug.
    If they do, we will respond to their concerns and have a productive
    discussion.  "Established user base" carries a lot of weight with
    Linus - not enough to suppress the gag-reflex, but enough to ignore the
    whiners.  So if we had well-documented cases of people using the
    code that is in Linux, and indications of interest from other
    stake holders, that would be an important part of the sell.

I think part of our problem is that we can't get an established user base.  It's the proverbial chicken and an egg.  The Lustre client in staging is not at all modern enough.  The out-of-tree server has significant capabilities that the in-tree client can't leverage.  Who would use the in-tree client?  I hope that there is a way out of staging because only then will we be able to bring the user base.

On 5/22/18, 5:08 PM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:

    I think we should do one thing at a time.
    Firstly, focus on getting out of staging.  Freeze the current feature
    set and get all existing features into an acceptable form.

Do we really have to keep the current feature set?  Is it a hard and fast rule or just your advice?  Most of the Lustre community is going to Lustre version 2.10.  If we could at least get the 2.10 feature content into the staging client, then we'd have a much greater chance of building a user community.

    It might help to start using the mailing list more, rather than
    depending on whamcloud.  The work-flow is different, but is quite
    workable, and shows a willingness to be part of the broader community.

Well, the Lustre community is hosted by services supplied by Intel.  We're going to have to talk about getting the development effort from the community and vendors into the mailing list then.  The server is still out-of-tree though and it will be much harder to develop capabilities across a mailing list and the (imho, more modern) development tools hosted by Intel.  I don't think that the rest of the Lustre development community really understands what it is going to take to shift the development effort to mailing lists.  I don't.  Maybe having that conversation now will help us determine our path forward.

    Thanks,
    NeilBrown

Neil, thank you.  It's really great to have your help on this effort.  We wouldn't be talking about getting out of staging like this without you and James S.

-Cory
    
