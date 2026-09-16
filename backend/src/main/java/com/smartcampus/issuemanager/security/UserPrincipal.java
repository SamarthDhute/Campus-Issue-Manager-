package com.smartcampus.issuemanager.security;

import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.entity.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Getter
@AllArgsConstructor
public class UserPrincipal implements UserDetails {

    private final UUID id;
    private final String email;
    private final String password;
    private final String displayName;
    private final Role role;
    private final UUID organizationId;
    private final Collection<? extends GrantedAuthority> authorities;

    public static UserPrincipal create(User user) {
        List<GrantedAuthority> authorities = List.of(
            new SimpleGrantedAuthority("ROLE_" + user.getRole().name())
        );

        UUID orgId = user.getOrganization() != null ? user.getOrganization().getId() : null;

        return new UserPrincipal(
            user.getId(),
            user.getEmail(),
            user.getPasswordHash(),
            user.getDisplayName(),
            user.getRole(),
            orgId,
            authorities
        );
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
