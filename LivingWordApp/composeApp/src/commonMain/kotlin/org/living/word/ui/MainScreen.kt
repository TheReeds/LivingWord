package org.living.word.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.BottomNavigation
import androidx.compose.material.BottomNavigationItem
import androidx.compose.material.Card
import androidx.compose.material.Icon
import androidx.compose.material.IconButton
import androidx.compose.material.Scaffold
import androidx.compose.material.Text
import androidx.compose.material.TopAppBar
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBox
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Done
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.filled.ThumbUp
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun MainScreen() {
    var activeTab by remember { mutableStateOf("home") }

    val quickAccessOptions = listOf(
        QuickAccessOption(Icons.Default.Call, "Live"),
        QuickAccessOption(Icons.Default.Done, "Listen"),
        QuickAccessOption(Icons.Default.Favorite, "Donate"),
        QuickAccessOption(Icons.Default.DateRange, "Groups"),
        QuickAccessOption(Icons.Default.MoreVert, "Give"),
        QuickAccessOption(Icons.Default.Notifications, "Alerts"),
        QuickAccessOption(Icons.Default.Build, "Connect"),
        QuickAccessOption(Icons.Default.Menu, "More")
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Living Word",
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                },
                backgroundColor = Color(0xFF3B82F6),
                elevation = 8.dp
            )
        },
        bottomBar = {
            BottomNavigationBar(activeTab) { selectedTab -> activeTab = selectedTab }
        },
        content = {
            MainContent(activeTab, quickAccessOptions)
        }
    )
}

@Composable
fun MainContent(activeTab: String, quickAccessOptions: List<QuickAccessOption>) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .background(Color(0xFFF3F4F6)),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        when (activeTab) {
            "home" -> HomeContent(quickAccessOptions)
            "events" -> CenteredText("Upcoming Events")
            "sermons" -> CenteredText("Latest Sermons")
            "worship" -> CenteredText("Worship Playlist")
            "more" -> CenteredText("More Options")
        }
    }
}

@Composable
fun HomeContent(quickAccessOptions: List<QuickAccessOption>) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Welcome to LivingWord Church",
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF1E40AF), // Dark blue text
            modifier = Modifier.padding(bottom = 16.dp)
        )

        QuickAccessGrid(quickAccessOptions)

        Spacer(modifier = Modifier.height(16.dp))

        // Upcoming Events
        Card(
            modifier = Modifier.fillMaxWidth(),
            backgroundColor = Color.White,
            elevation = 4.dp
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(text = "Upcoming Events", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                Spacer(modifier = Modifier.height(8.dp))
                Text(text = "Bible Study - Tuesday 7PM", fontSize = 14.sp, color = Color.Gray)
                Text(text = "Youth Group - Friday 6PM", fontSize = 14.sp, color = Color.Gray)
                Text(text = "Community Outreach - Saturday 10AM", fontSize = 14.sp, color = Color.Gray)
            }
        }
    }
}

@Composable
fun QuickAccessGrid(quickAccessOptions: List<QuickAccessOption>) {
    Column {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
            quickAccessOptions.take(4).forEach { QuickAccessItem(it) }
        }
        Spacer(modifier = Modifier.height(16.dp))
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
            quickAccessOptions.drop(4).take(4).forEach { QuickAccessItem(it) }
        }
    }
}

@Composable
fun QuickAccessItem(option: QuickAccessOption) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        IconButton(
            onClick = { /* Handle click */ },
            modifier = Modifier
                .size(56.dp)
                .background(Color(0xFF93C5FD), shape = CircleShape) // Light blue background
        ) {
            Icon(
                imageVector = option.icon,
                contentDescription = option.label,
                tint = Color.White,
                modifier = Modifier.size(28.dp)
            )
        }
        Text(
            text = option.label,
            fontSize = 12.sp,
            modifier = Modifier.padding(top = 8.dp),
            color = Color.Gray
        )
    }
}

@Composable
fun BottomNavigationBar(activeTab: String, onTabSelected: (String) -> Unit) {
    BottomNavigation(
        backgroundColor = Color.White,
        elevation = 8.dp
    ) {
        BottomNavigationItem(
            icon = { Icon(Icons.Default.Home, contentDescription = "Home") },
            label = { Text("Home") },
            selected = activeTab == "home",
            onClick = { onTabSelected("home") },
            selectedContentColor = Color(0xFF3B82F6),
            unselectedContentColor = Color.Gray
        )
        BottomNavigationItem(
            icon = { Icon(Icons.Default.ShoppingCart, contentDescription = "Events") },
            label = { Text("Events") },
            selected = activeTab == "events",
            onClick = { onTabSelected("events") },
            selectedContentColor = Color(0xFF3B82F6),
            unselectedContentColor = Color.Gray
        )
        BottomNavigationItem(
            icon = { Icon(Icons.Default.AccountBox, contentDescription = "Sermons") },
            label = { Text("Sermons") },
            selected = activeTab == "sermons",
            onClick = { onTabSelected("sermons") },
            selectedContentColor = Color(0xFF3B82F6),
            unselectedContentColor = Color.Gray
        )
        BottomNavigationItem(
            icon = { Icon(Icons.Default.ThumbUp, contentDescription = "Worship") },
            label = { Text("Worship") },
            selected = activeTab == "worship",
            onClick = { onTabSelected("worship") },
            selectedContentColor = Color(0xFF3B82F6),
            unselectedContentColor = Color.Gray
        )
        BottomNavigationItem(
            icon = { Icon(Icons.Default.Menu, contentDescription = "More") },
            label = { Text("More") },
            selected = activeTab == "more",
            onClick = { onTabSelected("more") },
            selectedContentColor = Color(0xFF3B82F6),
            unselectedContentColor = Color.Gray
        )
    }
}

@Composable
fun CenteredText(text: String) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Text(text = text, fontSize = 24.sp, fontWeight = FontWeight.Bold)
    }
}

data class QuickAccessOption(val icon: androidx.compose.ui.graphics.vector.ImageVector, val label: String)
